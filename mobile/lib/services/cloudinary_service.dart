import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static const String _cloudName = "drxzspnki";
  static const String _uploadPreset = "krishi_suraksha_saat_baara";
  // ------------------------------------
  
  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<String> uploadFile(File file, String claimID, String farmerID) async {
    try {
      String folder = "agri-claim-app/farmers/$farmerID/claims/$claimID";
      
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path,
          folder: folder,
          publicId: file.path.split('/').last, 
        ),
      );
      
      return response.secureUrl; // Returns the "https://..." URL
      
    } catch (e) {
      print('Cloudinary upload error: $e');
      throw Exception('Failed to upload file to Cloudinary: $e');
    }
  }
  
  Future<String> uploadLandRecord(File file, String farmID, String farmerID) async {
     try {
      String folder = "agri-claim-app/farmers/$farmerID/farms/$farmID";
      
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path,
          folder: folder,
          publicId: file.path.split('/').last, 
        ),
      );
      
      return response.secureUrl; // Returns the "https://..." URL
      
    } catch (e) {
      print('Cloudinary upload error: $e');
      throw Exception('Failed to upload file to Cloudinary: $e');
    }
  }
}