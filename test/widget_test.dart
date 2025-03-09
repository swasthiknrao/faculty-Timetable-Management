// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/main.dart';
import '../lib/theme_provider.dart';
import '../lib/utils/lab_hours_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    final labHoursProvider = LabHoursProvider();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: labHoursProvider),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the login page is shown
    expect(find.text('College Management'), findsOneWidget);
  });
}
