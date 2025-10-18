import 'package:flutter/material.dart';
import 'screens/auth/login_page.dart'; // Change to login page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krishi Suraksha',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(), // Changed to LoginPage
      debugShowCheckedModeBanner: false,
    );
  }
}
