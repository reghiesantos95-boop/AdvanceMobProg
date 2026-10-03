import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';
import 'signin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    context.read<CartProvider>().clear();
    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      SignInScreen.routeName,
      (route) => false,
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final password = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This action signs you out and cannot be undone.'),
            if (user.loginType == LoginType.firebase) ...[
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    final currentPassword = password.text;
    password.dispose();
    if (confirmed != true || !context.mounted) return;

    final deleted = await context.read<AuthProvider>().deleteAccount(
      currentPassword,
    );
    if (!context.mounted) return;
    if (deleted) {
      context.read<CartProvider>().clear();
      Navigator.pushNamedAndRemoveUntil(
        context,
        SignInScreen.routeName,
        (route) => false,
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not delete the account.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Settings',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: SwitchListTile(
                // Enhancement 3: dark/light mode was moved from the home page
                // into this settings page.
                value: themeProvider.isDark,
                onChanged: (_) => themeProvider.toggleTheme(),
                secondary: Icon(
                  themeProvider.isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                title: const CustomText(
                  text: 'Dark Mode',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                subtitle: CustomText(
                  text: themeProvider.isDark
                      ? 'Using dark theme'
                      : 'Using light theme',
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: CustomText(
                  text: user?.fullName ?? 'Guest',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                subtitle: CustomText(
                  text: user?.loginType == LoginType.firebase
                      ? 'Firebase account'
                      : 'DummyJSON account',
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: user == null ? null : () => _deleteAccount(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Account'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
