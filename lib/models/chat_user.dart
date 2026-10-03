class ChatUser {
  const ChatUser({
    required this.uid,
    required this.name,
    required this.email,
  });

  final String uid;
  final String name;
  final String email;

  factory ChatUser.fromMap(Map<String, dynamic> map, String documentId) {
    final email = (map['email'] ?? '').toString();
    final storedName = (map['name'] ?? '').toString().trim();
    return ChatUser(
      uid: (map['uid'] ?? documentId).toString(),
      name: storedName.isEmpty ? email.split('@').first : storedName,
      email: email,
    );
  }
}
