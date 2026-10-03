import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/firebase_auth_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  static const String _userStorageKey = 'saved_user';

  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> restoreSession() async {
    // Enhancement 1: splash screen uses this persistent authentication state.
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString(_userStorageKey);

    if (savedUser == null) {
      return false;
    }

    _user = User.fromStoredJson(savedUser);
    notifyListeners();
    return true;
  }

  Future<bool> signIn(
    String identity,
    String password, {
    LoginType loginType = LoginType.dummyJson,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Enhancement 2: sign in screen calls UserService for authentication.
      _user = loginType == LoginType.firebase
          ? await FirebaseAuthService.instance.signIn(
              email: identity,
              password: password,
            )
          : await _userService.login(username: identity, password: password);
      await _saveUser();
      return true;
    } catch (error) {
      _errorMessage =
          'Unable to sign in. Check your credentials and try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_user?.loginType == LoginType.firebase) {
      await FirebaseAuthService.instance.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userStorageKey);
    _user = null;
    notifyListeners();
  }

  Future<bool> createAccount({
    required String firstName,
    required String lastName,
    required int age,
    required String phone,
    required String username,
    required String email,
    required String password,
    required LoginType loginType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = loginType == LoginType.firebase
          ? await FirebaseAuthService.instance.createAccount(
              firstName: firstName,
              lastName: lastName,
              email: email,
              password: password,
            )
          : await _userService.createAccount(
              firstName: firstName,
              lastName: lastName,
              age: age,
              phone: phone,
              username: username,
              email: email,
              password: password,
            );
      await _saveUser();
      return true;
    } catch (_) {
      _errorMessage =
          'Unable to create account. Please check the form and try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    if (_user == null || _user!.loginType != LoginType.dummyJson) {
      return;
    }
    _user = await _userService.getUserData(_user!);
    await _saveUser();
    notifyListeners();
  }

  Future<bool> updateUsername(String username) async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = _user!.loginType == LoginType.firebase
          ? await FirebaseAuthService.instance.updateUsername(username)
          : await _userService.updateUsername(_user!, username);
      await _saveUser();
      return true;
    } catch (_) {
      _errorMessage = 'Unable to update username.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_user!.loginType == LoginType.firebase) {
        await FirebaseAuthService.instance.resetPasswordFromCurrentPassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
      } else {
        await _userService.resetPasswordFromCurrentPassword(
          user: _user!,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
      }
      return true;
    } catch (_) {
      _errorMessage = 'Unable to update password. Check your current password.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount(String currentPassword) async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_user!.loginType == LoginType.firebase) {
        await FirebaseAuthService.instance.deleteAccount(currentPassword);
      } else {
        await _userService.deleteAccount(_user!);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userStorageKey);
      _user = null;
      return true;
    } catch (_) {
      _errorMessage = 'Unable to delete account.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStorageKey, _user!.encode());
  }
}
