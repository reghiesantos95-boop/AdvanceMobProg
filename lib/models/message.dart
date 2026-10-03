import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.text,
    required this.sentAt,
    required this.status,
  });

  final String id;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String text;
  final DateTime sentAt;
  final String status;

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    final timestamp = map['timestamp'];
    return Message(
      id: id,
      senderId: (map['senderId'] ?? '').toString(),
      senderEmail: (map['senderEmail'] ?? '').toString(),
      receiverId: (map['receiverId'] ?? '').toString(),
      text: (map['message'] ?? '').toString(),
      sentAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      status: (map['status'] ?? 'delivered').toString(),
    );
  }
}
