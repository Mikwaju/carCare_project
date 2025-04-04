import 'package:carcare/DashboardPage.dart';
import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'LoginPage.dart';
import 'SignUpPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarCare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => SignUpPage(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}