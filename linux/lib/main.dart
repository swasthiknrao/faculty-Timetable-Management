import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'theme_provider.dart';
import 'utils/responsive_util.dart';
import 'utils/lab_hours_provider.dart';

void main() {
  final themeProvider = ThemeProvider();
  final labHoursProvider = LabHoursProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: labHoursProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'College Management',
          theme: themeProvider.theme,
          home: Builder(
            builder: (context) {
              ResponsiveUtil().init(context);
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}
