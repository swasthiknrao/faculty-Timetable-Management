import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'utils/theme_provider.dart';
import 'utils/responsive_util.dart';
import 'utils/lab_hours_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  final labHoursProvider = LabHoursProvider();
  await Future.delayed(
      const Duration(milliseconds: 100)); // Wait for theme to load

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
