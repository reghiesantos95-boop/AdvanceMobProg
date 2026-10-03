import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/user.dart';
import '../widgets/custom_text.dart';
import 'signin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut(BuildContext context) async {
    context.read<CartProvider>().clear();
    await context.read<AuthProvider>().signOut();

    if (!context.mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      SignInScreen.routeName,
      (route) => false,
    );
  }

  Future<void> _editUsername() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final controller = TextEditingController(text: user.username);
    final username = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || username == null || username.isEmpty) return;
    final updated = await context.read<AuthProvider>().updateUsername(username);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated ? 'Username updated.' : 'Could not update username.',
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final values = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (current.text, next.text)),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    current.dispose();
    next.dispose();
    if (!mounted || values == null) return;
    final updated = await context
        .read<AuthProvider>()
        .resetPasswordFromCurrentPassword(
          currentPassword: values.$1,
          newPassword: values.$2,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated ? 'Password updated.' : 'Could not update password.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final colors = Theme.of(context).colorScheme;

    if (user == null) {
      return const Center(
        child: CustomText(text: 'No profile data found.', fontSize: 14),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundImage: user.image.isEmpty
                      ? null
                      : NetworkImage(user.image),
                  child: user.image.isEmpty ? const Icon(Icons.person) : null,
                ),
                const SizedBox(height: 12),
                CustomText(
                  // Enhancement 3: profile screen renders the saved user model.
                  text: user.fullName,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: '@${user.username}',
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _editUsername,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit username'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _changePassword,
                        icon: const Icon(Icons.password_outlined),
                        label: const Text('Password'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ProfileRow(icon: Icons.email, label: user.email),
                _ProfileRow(icon: Icons.phone, label: user.phone),
                _ProfileRow(icon: Icons.school, label: user.university),
                _ProfileRow(icon: Icons.badge, label: user.role),
                _ProfileRow(
                  icon: Icons.verified_user_outlined,
                  label: user.loginType == LoginType.firebase
                      ? 'Firebase Authentication'
                      : 'DummyJSON',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _signOut(context),
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: CustomText(
              text: label.isEmpty ? 'N/A' : label,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
