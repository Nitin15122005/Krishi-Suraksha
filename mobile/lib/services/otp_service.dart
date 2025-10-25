import 'dart:math';
import 'package:flutter/foundation.dart';

class OtpService {
  // Generate random 6-digit OTP
  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Simulate OTP sending (Replace with actual SMS service)
  Future<bool> sendOtp(String phone, String otp) async {
    try {
      // TODO: Integrate with actual SMS service like:
      // - Twilio
      // - MSG91
      // - Fast2SMS
      // - Your custom SMS gateway

      // For now, just simulate delay
      await Future.delayed(const Duration(seconds: 2));

      if (kDebugMode) {
        debugPrint('OTP sent to $phone: $otp');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending OTP: $e');
      }
      return false;
    }
  }

  // Simulate Aadhaar OTP (would integrate with UIDAI in production)
  Future<bool> sendAadhaarOtp(String aadhaar) async {
    try {
      // TODO: Integrate with UIDAI API for Aadhaar verification
      // This is a mock implementation

      await Future.delayed(const Duration(seconds: 2));

      if (kDebugMode) {
        debugPrint('Aadhaar OTP sent for: $aadhaar');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending Aadhaar OTP: $e');
      }
      return false;
    }
  }

  // Validate phone number format
  bool isValidPhone(String phone) {
    return phone.length == 10 && int.tryParse(phone) != null;
  }

  // Validate Aadhaar number format
  bool isValidAadhaar(String aadhaar) {
    return aadhaar.length == 12 && int.tryParse(aadhaar) != null;
  }

  // Check if OTP is expired (5 minutes)
  bool isOtpExpired(DateTime createdAt) {
    final now = DateTime.now();
    return now.difference(createdAt).inMinutes > 5;
  }
}
