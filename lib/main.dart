import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hamilton_car_service/screens/splash_screen.dart';

import 'screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HamiltonCarServiceApp());
}

class HamiltonCarServiceApp extends StatelessWidget {
  const HamiltonCarServiceApp({super.key});

  static const Color _accentRed = Color(0xFFB71C1C);

  //test git
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
      home: const SplashScreen(),
    );
  }
}
