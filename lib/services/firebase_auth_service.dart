import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../models/user.dart';
import 'chat_service.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuthService instance = FirebaseAuthService._();

  firebase.FirebaseAuth get _auth => firebase.FirebaseAuth.instance;

  Future<User> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await ChatService.instance.syncUser(credential.user!);
    return _toAppUser(credential.user!);
  }

  Future<User> createAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName('$firstName $lastName'.trim());
    await credential.user!.reload();
    await ChatService.instance.syncUser(_auth.currentUser!);
    return _toAppUser(_auth.currentUser!);
  }

  Future<User> updateUsername(String username) async {
    final user = _requireUser();
    await user.updateDisplayName(username);
    await user.reload();
    await ChatService.instance.syncUser(_auth.currentUser!);
    return _toAppUser(_auth.currentUser!);
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    final credential = firebase.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount(String currentPassword) async {
    final user = _requireUser();
    final credential = firebase.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.delete();
  }

  Future<void> signOut() => _auth.signOut();

  firebase.User _requireUser() {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('No Firebase account is signed in.');
    }
    return user;
  }

  User _toAppUser(firebase.User user) {
    final parts = (user.displayName ?? '').trim().split(' ');
    final email = user.email ?? '';
    return User(
      id: user.uid.hashCode,
      username: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : email.split('@').first,
      firstName: parts.isEmpty ? '' : parts.first,
      lastName: parts.length > 1 ? parts.skip(1).join(' ') : '',
      email: email,
      gender: '',
      image: user.photoURL ?? '',
      accessToken: '',
      phone: user.phoneNumber ?? '',
      university: '',
      role: '',
      loginType: LoginType.firebase,
    );
  }
}
