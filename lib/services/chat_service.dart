import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../models/chat_user.dart';
import '../models/message.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncUser(firebase.User user) {
    final email = user.email ?? '';
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : email.split('@').first;

    return _firestore.collection('Users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<ChatUser>> users() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      final users = snapshot.docs
          .map((document) => ChatUser.fromMap(document.data(), document.id))
          .where((user) => user.uid.isNotEmpty)
          .toList();
      users.sort((first, second) => first.name.compareTo(second.name));
      return users;
    });
  }

  Future<void> sendMessage({
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required String text,
  }) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId(senderId, receiverId))
        .collection('messages')
        .add({
          'senderId': senderId,
          'senderEmail': senderEmail,
          'receiverId': receiverId,
          'message': text,
          'timestamp': Timestamp.now(),
          'status': 'delivered',
        });
  }

  Stream<List<Message>> messages(String firstUserId, String secondUserId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId(firstUserId, secondUserId))
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => Message.fromMap(document.data(), document.id))
              .toList(),
        );
  }

  Future<void> markMessagesAsSeen({
    required String currentUserId,
    required String otherUserId,
    required List<Message> messages,
  }) async {
    final unread = messages
        .where(
          (message) =>
              message.receiverId == currentUserId && message.status != 'seen',
        )
        .toList();
    if (unread.isEmpty) {
      return;
    }

    final room = _firestore.collection('chat_rooms').doc(
          chatRoomId(currentUserId, otherUserId),
        );
    final batch = _firestore.batch();
    for (final message in unread) {
      batch.update(room.collection('messages').doc(message.id), {
        'status': 'seen',
      });
    }
    await batch.commit();
  }

  String chatRoomId(String firstUserId, String secondUserId) {
    final ids = [firstUserId, secondUserId]..sort();
    return ids.join('_');
  }
}
