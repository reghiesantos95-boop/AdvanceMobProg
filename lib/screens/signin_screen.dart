import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/user.dart';
import '../widgets/custom_text.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = '/signin';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'emilys');
  final _passwordController = TextEditingController(text: 'emilyspass');
  LoginType _loginType = LoginType.dummyJson;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    final didSignIn = await authProvider.signIn(
      _usernameController.text.trim(),
      _passwordController.text,
      loginType: _loginType,
    );

    if (!mounted) {
      return;
    }

    if (didSignIn) {
      final user = authProvider.user;
      if (user != null && user.loginType == LoginType.dummyJson) {
        await cartProvider.loadCartForUser(user.id);
      }
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 42),
            Icon(Icons.shopping_bag, size: 62, color: colors.primary),
            const SizedBox(height: 18),
            const CustomText(
              text: 'Welcome back',
              fontSize: 30,
              fontWeight: FontWeight.w900,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: _loginType == LoginType.dummyJson
                  ? 'Sign in to load your DummyJSON profile and cart'
                  : 'Sign in with your Firebase email and password',
              fontSize: 14,
              color: colors.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SegmentedButton<LoginType>(
                    segments: const [
                      ButtonSegment(
                        value: LoginType.dummyJson,
                        icon: Icon(Icons.api_outlined),
                        label: Text('DummyJSON'),
                      ),
                      ButtonSegment(
                        value: LoginType.firebase,
                        icon: Icon(Icons.lock_outline),
                        label: Text('Firebase'),
                      ),
                    ],
                    selected: {_loginType},
                    onSelectionChanged: (selection) {
                      setState(() => _loginType = selection.first);
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: _loginType == LoginType.firebase
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: _loginType == LoginType.firebase
                          ? 'Email address'
                          : 'Username',
                      prefixIcon: Icon(
                        _loginType == LoginType.firebase
                            ? Icons.email_outlined
                            : Icons.person,
                      ),
                    ),
                    validator: (value) {
                      return value == null || value.trim().isEmpty
                          ? 'Enter username'
                          : null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      return value == null || value.isEmpty
                          ? 'Enter password'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (authProvider.errorMessage != null)
                    CustomText(
                      text: authProvider.errorMessage!,
                      fontSize: 13,
                      color: colors.error,
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      // Enhancement 2: sign in UI uses UserService through
                      // AuthProvider and persists successful authentication.
                      onPressed: authProvider.isLoading ? null : _submit,
                      icon: authProvider.isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: const Text('Sign In'),
                    ),
                  ),
                  TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => Navigator.pushNamed(
                            context,
                            SignUpScreen.routeName,
                          ),
                    child: const Text('Create a new account'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
