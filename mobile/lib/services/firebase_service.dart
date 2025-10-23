import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  // User Management
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // ========== OTP AND VERIFICATION METHODS ==========

  // Check if phone number already exists
  Future<bool> isPhoneNumberExists(String phone) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('profile.phone', isEqualTo: phone)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking phone number: $e');
      }
      return false;
    }
  }

  // Check if Aadhaar number already exists
  Future<bool> isAadhaarNumberExists(String aadhaar) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('profile.aadhaarNumber', isEqualTo: aadhaar)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking Aadhaar number: $e');
      }
      return false;
    }
  }

  // Store OTP data temporarily
  Future<void> storeOtpData(String identifier, String otp, String type) async {
    try {
      await _firestore.collection('otp_verifications').doc(identifier).set({
        'otp': otp,
        'type': type, // 'phone' or 'aadhaar'
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error storing OTP: $e');
      }
      rethrow;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String identifier, String enteredOtp) async {
    try {
      final doc = await _firestore
          .collection('otp_verifications')
          .doc(identifier)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final storedOtp = data['otp'] as String;
        final createdAt = data['createdAt'] as Timestamp;

        // Check if OTP is expired (5 minutes)
        final now = DateTime.now();
        final createdTime = createdAt.toDate();
        final difference = now.difference(createdTime).inMinutes;

        if (difference <= 5 && storedOtp == enteredOtp) {
          // Delete OTP after successful verification
          await _firestore
              .collection('otp_verifications')
              .doc(identifier)
              .delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verifying OTP: $e');
      }
      return false;
    }
  }

  // Create user in Firebase with hashed password
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final String farmerId = userData['farmerId'];
      final passwordData =
          _authService.createPasswordHash(userData['password']);

      await _firestore.collection('users').doc(farmerId).set({
        'profile': {
          'farmerId': farmerId,
          'name': userData['name'],
          'phone': userData['phone'],
          'password': passwordData['password'], // Hashed password
          'salt': passwordData['salt'], // Store salt for verification
          'address': userData['address'],
          'aadhaarNumber': userData['aadhaarNumber'],
          'farmIds': [], // Initialize empty farm IDs array
        },
        'aadhaarVerification': {
          'isVerified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
        },
        'session': {
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('User created successfully in Firebase: $farmerId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating user in Firebase: $e');
      }
      rethrow;
    }
  }

  // Get user by phone number
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('profile.phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user by phone: $e');
      }
      return null;
    }
  }

  // Get user by Aadhaar number
  Future<Map<String, dynamic>?> getUserByAadhaar(String aadhaar) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('profile.aadhaarNumber', isEqualTo: aadhaar)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user by Aadhaar: $e');
      }
      return null;
    }
  }

  // Verify login credentials with hashed password
  Future<bool> verifyLogin(String phone, String password) async {
    try {
      final userData = await getUserByPhone(phone);
      if (userData != null) {
        final profile = userData['profile'] as Map<String, dynamic>?;
        final storedHashedPassword = profile?['password'] as String?;
        final salt = profile?['salt'] as String?;

        if (storedHashedPassword != null && salt != null) {
          return _authService.verifyPassword(
              password, storedHashedPassword, salt);
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verifying login: $e');
      }
      return false;
    }
  }

  // ========== FILE UPLOAD METHODS ==========

  // File Upload Methods
  Future<String> uploadFile(File file, String storagePath) async {
    try {
      if (kDebugMode) {
        debugPrint('Uploading file to: $storagePath');
      }

      Reference storageReference = _storage.ref().child(storagePath);
      UploadTask uploadTask = storageReference.putFile(file);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        debugPrint('File uploaded successfully: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<File> getFileFromPath(String filePath) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        return file;
      } else {
        throw Exception('File does not exist at path: $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting file: $e');
      }
      rethrow;
    }
  }

  // Image-specific upload
  Future<String> uploadImage(File imageFile, String userId) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    String storagePath = 'users/$userId/images/$fileName';

    return await uploadFile(imageFile, storagePath);
  }

  // Document upload
  Future<String> uploadDocument(
      File documentFile, String userId, String documentType) async {
    String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$documentType.pdf';
    String storagePath = 'users/$userId/documents/$fileName';

    return await uploadFile(documentFile, storagePath);
  }

  // ========== FIRESTORE OPERATIONS ==========

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));

        if (kDebugMode) {
          debugPrint('User data saved successfully for: ${user.uid}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving user data: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user data: $e');
      }
      rethrow;
    }
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);

      if (kDebugMode) {
        debugPrint('User profile updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  // Add farm to user's farmIds array
  Future<void> addFarmToUser(String userId, String farmId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profile.farmIds': FieldValue.arrayUnion([farmId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('Farm $farmId added to user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding farm to user: $e');
      }
      rethrow;
    }
  }

  // ========== FILE MANAGEMENT ==========

  // File download
  Future<File> downloadFile(String url, String localPath) async {
    try {
      if (kDebugMode) {
        debugPrint('Downloading file from: $url');
      }

      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();

      File file = File(localPath);
      await response.pipe(file.openWrite());

      if (kDebugMode) {
        debugPrint('File downloaded to: $localPath');
      }

      return file;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error downloading file: $e');
      }
      rethrow;
    }
  }

  // Delete file from storage
  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).delete();

      if (kDebugMode) {
        debugPrint('File deleted successfully: $storagePath');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting file: $e');
      }
      rethrow;
    }
  }

  // Check if file exists
  Future<bool> fileExists(String storagePath) async {
    try {
      final ListResult result =
          await _storage.ref().child(storagePath).listAll();
      return result.items.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking file existence: $e');
      }
      return false;
    }
  }

  // Batch operations
  Future<List<String>> uploadMultipleFiles(
      List<File> files, String baseStoragePath) async {
    try {
      List<String> downloadUrls = [];

      for (int i = 0; i < files.length; i++) {
        String storagePath =
            '$baseStoragePath/file_${DateTime.now().millisecondsSinceEpoch}_$i';
        String downloadUrl = await uploadFile(files[i], storagePath);
        downloadUrls.add(downloadUrl);
      }

      if (kDebugMode) {
        debugPrint('${files.length} files uploaded successfully');
      }

      return downloadUrls;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error uploading multiple files: $e');
      }
      rethrow;
    }
  }

  // ========== UTILITY METHODS ==========

  // Utility method to get file size
  Future<int> getFileSize(File file) async {
    try {
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting file size: $e');
      }
      return 0;
    }
  }

  // Utility method to get file extension
  String getFileExtension(File file) {
    try {
      String path = file.path;
      return path.split('.').last;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting file extension: $e');
      }
      return '';
    }
  }

  // Generate random OTP
  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Update user session
  Future<void> updateUserSession(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'session.lastLogin': FieldValue.serverTimestamp(),
        'session.isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating user session: $e');
      }
    }
  }

  // Sign out user
  Future<void> signOutUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'session.isActive': false,
        'session.lastLogout': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating logout status: $e');
      }
    }
  }
}
