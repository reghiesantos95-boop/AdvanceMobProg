import 'package:flutter_test/flutter_test.dart';

import 'package:santos_advmobprog/main.dart';

void main() {
  testWidgets('shows e-commerce app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const SantosAdvMobProg());

    expect(find.text('Men Fashion'), findsWidgets);
    expect(find.text('Search men fashion'), findsOneWidget);
  });
}
