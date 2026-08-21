import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stampit_app/views/welcome_view.dart';

void main() {
  testWidgets('WelcomeView shows sign-in options', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeView()));

    expect(find.text('StampIt'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign in as staff'), findsOneWidget);
  });
}
