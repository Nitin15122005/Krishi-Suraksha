import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart'; 
import 'package:agri_claim_mobile/services/storage_service.dart';
import '../models/farm_details_model.dart'; 
import 'package:url_launcher/url_launcher.dart';
import '../models/farm_model.dart';
import '../models/bank_details_model.dart';

class RegistrationResponse {
  final String farmerID;
  final String name;
  final String address;
  final String mobile;
  final String token;

  RegistrationResponse({
    required this.farmerID,
    required this.name,
    required this.address,
    required this.mobile,
    required this.token,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      farmerID: json['farmerID'],
      name: json['name'],
      address: json['address'],
      mobile: json['mobile'],
      token: json['token'],
    );
  }
}

class LoginResponse {
  final String farmerID;
  final String name;
  final String address;
  final String mobile;
  final String token;

  LoginResponse({
    required this.farmerID,
    required this.name,
    required this.address,
    required this.mobile,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      farmerID: json['farmerID'],
      name: json['name'],
      address: json['address'],
      mobile: json['mobile'],
      token: json['token'],
    );
  }
}

class ApiService {
  // final String _baseUrl = "http://172.20.45.168:3000"; 
  // final String _baseUrl = "http://10.217.116.113:3000";
  // On Android emulator, use: "http://10.0.2.2:8080"
  final String _baseUrl = "http://127.0.0.1:3000";
  final StorageService _storageService = StorageService();

  Future<String> requestOtp(String mobile, String aadhar) async {
    final url = Uri.parse('$_baseUrl/request-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobile, 'aadhar': aadhar}),
      );
      
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['message']; // "OTP has been sent..."
      } else {
        throw Exception(data['error'] ?? 'Failed to request OTP');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<RegistrationResponse> verifyOtpAndRegister(String mobile, String aadhar, String otp, String password) async {
    final url = Uri.parse('$_baseUrl/verify-otp-and-register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobile, 'aadhar': aadhar, 'otp': otp, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return RegistrationResponse.fromJson(data);
      } else {
        throw Exception(data['error'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<AppWeather> getWeather(String lat, String lon) async {
    final url = Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AppWeather.fromJson(data);
      } else {
        throw Exception('Failed to load weather: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<LoginResponse> login(String mobile, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobile, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(data);
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  Future<String> addFarm({
    required String farmID,
    required List<Map<String, dynamic>> boundary,
    required String cropType,
    required String landRecordFileURL, // We now pass the URL
  }) async {
    
    final ownerFarmerID = await _storageService.getFarmerID();
    if (ownerFarmerID == null) {
      throw Exception("User not logged in.");
    }
    final token = await _storageService.getToken();

    final String locationJsonString = json.encode(boundary);
    
    final url = Uri.parse('$_baseUrl/addFarm');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'farmID': farmID,
          'ownerFarmerID': ownerFarmerID,
          'location': locationJsonString,
          'cropType': cropType,
          'landRecordHash': landRecordFileURL, // Pass the URL as the hash
        }),
      ).timeout(const Duration(seconds: 15));
      
      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return data['message'];
      } else {
        throw Exception(data['error'] ?? 'Failed to add farm');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  Future<List<Farm>> getFarms() async {
    final farmerID = await _storageService.getFarmerID();
    if (farmerID == null || farmerID.isEmpty) {
      throw Exception("No farmer ID found. Please log in again.");
    }

    final token = await _storageService.getToken();

    // 3. Call the Go backend endpoint
    final url = Uri.parse('$_baseUrl/farms/by-farmer/$farmerID');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Good practice
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> farmDataList = json.decode(response.body);

        return farmDataList.map((json) => Farm.fromJson(json)).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load farms');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  Future<FarmDetails> getFarmDetails(String farmID) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/farm-details/$farmID');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return FarmDetails.fromJson(data);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load farm details');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  // --- HELPER TO LAUNCH URL ---
  Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  Future<BankDetails?> getBankDetails() async {
    final mobile = await _storageService.getFarmerMobile();
    final token = await _storageService.getToken();
    if (mobile == null) throw Exception("User not logged in");

    final url = Uri.parse('$_baseUrl/bank-details?mobile=$mobile');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // If body is 'null' or empty, return null
        if (response.body.isEmpty || response.body == 'null') {
          return null; 
        }
        final data = json.decode(response.body);
        return BankDetails.fromJson(data);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load bank details');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }
  
  // --- NEW: Update Bank Details ---
  Future<BankDetails> saveBankDetails(BankDetails details) async {
    final mobile = await _storageService.getFarmerMobile();
    final token = await _storageService.getToken();
    if (mobile == null) throw Exception("User not logged in");

    final url = Uri.parse('$_baseUrl/bank-details?mobile=$mobile');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(details.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BankDetails.fromJson(data);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to save bank details');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }
 
  Future<String> submitClaim({
    required String claimID,
    required String farmID,
    required String reason, // This is the "Damage Type"
    required String damageDate,
    required List<String> evidenceHashes, // List of Cloudinary URLs
    required String description,
  }) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/submitClaim');

    // Convert the list of URLs to a JSON string for the chaincode
    final evidenceHashesJSON = json.encode(evidenceHashes);
    
    // Combine reason and description
    final fullReason = "$reason: $description";

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'claimID': claimID,
          'farmID': farmID,
          'reason': fullReason, // Send the combined reason
          'damageDate': damageDate,
          'evidenceHashes': evidenceHashesJSON, // Send the JSON string of URLs
        }),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 201) { // 201 Created
        return data['message'];
      } else {
        throw Exception(data['error'] ?? 'Failed to submit claim');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }  
}