// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_page.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/profile/profile_page.dart';
import 'models/user_model.dart';
import 'screens/claims/new_claim_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

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
            farmerId: "FARMER_001", // Updated to farmerId
            name: "John Farmer",
            email: "john.farmer@email.com",
            phoneNumber: "+91 9876543210",
            profileImage: null,
            isPhoneVerified: true,
            isAadhaarVerified: true,
            address: "Farm Address, Village, State",
            aadharNumber: "123456789012",
            farms: [
              FarmModel(
                farmId: "FARM_001",
                ownerFarmerId: "FARMER_001",
                location: "lat:19.0760,lon:72.8777",
                cropType: "Wheat",
                area: 5.2,
                description: "Main wheat farm",
              ),
            ],
            bankDetail: BankDetail(
              accountHolderName: "John Farmer",
              accountNumber: "12345678901",
              ifscCode: "SBIN0000123",
              bankName: "State Bank of India",
              branch: "Main Branch",
            ),
          );
          return ProfilePage(user: demoUser);
        },
      },
    );
  }
}
