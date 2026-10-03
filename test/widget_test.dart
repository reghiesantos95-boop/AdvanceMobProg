import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:santos_advmobprog/providers/auth_provider.dart';
import 'package:santos_advmobprog/screens/signin_screen.dart';

void main() {
  testWidgets('shows the connected store sign-in screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: SignInScreen()),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('DummyJSON'), findsOneWidget);
    expect(find.text('Firebase'), findsOneWidget);
  });
}
