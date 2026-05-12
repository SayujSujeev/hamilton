import 'package:flutter/material.dart';
import 'package:hamilton_car_service/screens/splash_screen.dart';

import 'screens/continue_with_google_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HamiltonCarServiceApp());
}

class HamiltonCarServiceApp extends StatelessWidget {
  const HamiltonCarServiceApp({super.key});

  static const Color _accentRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hamilton 44 Car Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentRed,
          brightness: Brightness.light,
          surface: const Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
    //  home: const ContinueWithGoogleScreen(),
      home :SplashScreen(nextScreen: ContinueWithGoogleScreen()),
    );
  }
}
