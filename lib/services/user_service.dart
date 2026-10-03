import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/user.dart';

class UserService {
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final body = jsonEncode({
      'username': username,
      'password': password,
      'expiresInMins': 60,
    });
    final headers = {'Content-Type': 'application/json'};

    var response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 404) {
      response = await http.post(
        Uri.parse('$host/user/login'),
        headers: headers,
        body: body,
      );
    }

    if (response.statusCode == 200) {
      final loginUser = User.fromJson(jsonDecode(response.body));
      return getUserById(loginUser.id, accessToken: loginUser.accessToken);
    }

    throw Exception('Invalid username or password');
  }

  Future<User> getUserById(int id, {String accessToken = ''}) async {
    final response = await http.get(Uri.parse('$host/users/$id'));

    if (response.statusCode == 200) {
      final userJson = jsonDecode(response.body) as Map<String, dynamic>;
      userJson['accessToken'] = accessToken;
      return User.fromJson(userJson);
    }

    throw Exception('Failed to load user profile');
  }

  Future<User> createAccount({
    required String firstName,
    required String lastName,
    required int age,
    required String phone,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$host/users/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'phone': phone,
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Could not create account');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    data['loginType'] = LoginType.dummyJson.name;
    return User.fromJson(data);
  }

  Future<User> getUserData(User user) async {
    if (user.loginType != LoginType.dummyJson) {
      return user;
    }
    try {
      return await getUserById(user.id, accessToken: user.accessToken);
    } catch (_) {
      return user;
    }
  }

  Future<User> updateUsername(User user, String username) async {
    final response = await http.put(
      Uri.parse('$host/users/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );
    if (response.statusCode != 200) {
      throw Exception('Could not update username');
    }
    return _mergeUser(user, jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> resetPasswordFromCurrentPassword({
    required User user,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty || newPassword.length < 8) {
      throw Exception(
        'Enter the current password and a new 8-character password',
      );
    }
    await login(username: user.username, password: currentPassword);
    final response = await http.put(
      Uri.parse('$host/users/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': newPassword}),
    );
    if (response.statusCode != 200) {
      throw Exception('Could not update password');
    }
  }

  Future<void> deleteAccount(User user) async {
    final response = await http.delete(Uri.parse('$host/users/${user.id}'));
    if (response.statusCode != 200) {
      throw Exception('Could not delete account');
    }
  }

  User _mergeUser(User original, Map<String, dynamic> update) {
    return User.fromJson({
      ...original.toJson(),
      ...update,
      'accessToken': original.accessToken,
      'loginType': original.loginType.name,
    });
  }
}
