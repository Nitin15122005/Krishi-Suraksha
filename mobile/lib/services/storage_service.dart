// 📍 FILE: services/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agri_claim_mobile/services/api_service.dart'; // For the response models

class StorageService {
  final _storage = const FlutterSecureStorage();

  // --- Keys ---
  static const _tokenKey = 'auth_token';
  static const _farmerIdKey = 'farmer_id';
  static const _farmerNameKey = 'farmer_name';
  static const _farmerMobileKey = 'farmer_mobile';
  static const _farmerAddressKey = 'farmer_address';

  // --- Save Session (on Login/Register) ---
  Future<void> saveSession(dynamic response) async {
    String token;
    String farmerID;
    String name;
    String mobile;
    String address;

    // Handle both response types
    if (response is RegistrationResponse) {
      token = response.token;
      farmerID = response.farmerID;
      name = response.name;
      mobile = response.mobile;
      address = response.address;
    } else if (response is LoginResponse) {
      token = response.token;
      farmerID = response.farmerID;
      name = response.name;
      mobile = response.mobile;
      address = response.address;
    } else {
      return; // Not a valid response
    }

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _farmerIdKey, value: farmerID);
    await _storage.write(key: _farmerNameKey, value: name);
    await _storage.write(key: _farmerMobileKey, value: mobile);
    await _storage.write(key: _farmerAddressKey, value: address);
  }

  // --- Clear Session (on Logout) ---
  Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  // --- Read Session Data ---
  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<String?> getFarmerID() => _storage.read(key: _farmerIdKey);
  Future<String?> getFarmerName() => _storage.read(key: _farmerNameKey);
  Future<String?> getFarmerMobile() => _storage.read(key: _farmerMobileKey);
  Future<String?> getFarmerAddress() => _storage.read(key: _farmerAddressKey);
}