import 'dart:convert';

enum LoginType { dummyJson, firebase }

class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String image;
  final String accessToken;
  final String phone;
  final String university;
  final String role;
  final int age;
  final LoginType loginType;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.phone,
    required this.university,
    required this.role,
    this.age = 0,
    this.loginType = LoginType.dummyJson,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'image': image,
      'accessToken': accessToken,
      'phone': phone,
      'university': university,
      'role': role,
      'age': age,
      'loginType': loginType.name,
    };
  }

  String encode() => jsonEncode(toJson());

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      phone: json['phone'] ?? '',
      university: json['university'] ?? '',
      role: json['role'] ?? '',
      age: json['age'] is num ? (json['age'] as num).toInt() : 0,
      loginType: LoginType.values.firstWhere(
        (type) => type.name == json['loginType'],
        orElse: () => LoginType.dummyJson,
      ),
    );
  }

  factory User.fromStoredJson(String value) {
    return User.fromJson(jsonDecode(value));
  }

  User copyWith({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    int? age,
    LoginType? loginType,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      gender: gender,
      image: image,
      accessToken: accessToken,
      phone: phone ?? this.phone,
      university: university,
      role: role,
      age: age ?? this.age,
      loginType: loginType ?? this.loginType,
    );
  }
}
