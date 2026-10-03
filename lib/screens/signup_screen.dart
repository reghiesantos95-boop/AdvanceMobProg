import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String routeName = '/signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  LoginType _loginType = LoginType.dummyJson;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _age.dispose();
    _phone.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final created = await context.read<AuthProvider>().createAccount(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      age: int.parse(_age.text.trim()),
      phone: _phone.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      loginType: _loginType,
    );
    if (!mounted || !created) return;
    context.read<CartProvider>().clear();
    Navigator.pushNamedAndRemoveUntil(
      context,
      HomeScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              const CustomText(
                text: 'Join Men Fashion',
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
              const SizedBox(height: 6),
              CustomText(
                text: 'Choose where this account is authenticated.',
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
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
              _field(_firstName, 'First name', Icons.person_outline),
              _field(_lastName, 'Last name', Icons.person_outline),
              _field(
                _age,
                'Age',
                Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final age = int.tryParse(value?.trim() ?? '');
                  return age == null || age < 13 || age > 120
                      ? 'Enter an age from 13 to 120'
                      : null;
                },
              ),
              _field(
                _phone,
                'Contact number',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _field(_username, 'Username', Icons.alternate_email),
              _field(
                _email,
                'Email address',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value?.contains('@') ?? false)
                    ? null
                    : 'Enter a valid email address',
              ),
              _field(
                _password,
                'Password',
                Icons.lock_outline,
                obscureText: true,
                validator: (value) => (value?.length ?? 0) >= 8
                    ? null
                    : 'Use at least 8 characters',
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 8),
                CustomText(
                  text: auth.errorMessage!,
                  fontSize: 13,
                  color: colors.error,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: auth.isLoading ? null : _submit,
                  icon: auth.isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator:
            validator ??
            (value) =>
                value == null || value.trim().isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}
