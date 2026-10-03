import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/user.dart';
import '../widgets/custom_text.dart';
import 'home_screen.dart';
import 'signin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    // Enhancement 1: custom splash screen checks SharedPreferences and skips
    // sign in when a saved authenticated user exists.
    final hasSession = await context.read<AuthProvider>().restoreSession();

    if (!mounted) {
      return;
    }

    if (hasSession) {
      final user = context.read<AuthProvider>().user;
      if (user != null && user.loginType == LoginType.dummyJson) {
        await context.read<CartProvider>().loadCartForUser(user.id);
      }
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, SignInScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.primaryContainer, colors.surface],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: colors.primary,
                child: Icon(
                  Icons.shopping_bag,
                  color: colors.onPrimary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 22),
              const CustomText(
                text: "Men's Fashion",
                fontSize: 30,
                fontWeight: FontWeight.w900,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              CustomText(
                text: 'Checking your saved session',
                fontSize: 14,
                color: colors.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
