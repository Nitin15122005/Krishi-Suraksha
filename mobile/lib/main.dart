// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'screens/auth/login_page.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/profile/profile_page.dart';
import 'models/user_model.dart';
import 'screens/claims/new_claim_page.dart';

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
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/new-claim': (context) => NewClaimPage(),
        '/profile': (context) {
          // For demo purposes - in real app, you'd get user from auth state
          final demoUser = UserModel(
            id: "1",
            name: "John Farmer",
            email: "john.farmer@email.com",
            phoneNumber: "+91 9876543210",
            profileImage: null,
          );
          return ProfilePage(user: demoUser);
        },
      },
    );
  }
}
