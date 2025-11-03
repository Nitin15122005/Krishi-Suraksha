import 'dart:convert';

class Farm {
  final String farmID;
  final String ownerFarmerID;
  final String location;
  final String cropType;
  final String landRecordHash;
  final String status;
  final String activeClaimID; 

  Farm({
    required this.farmID,
    required this.ownerFarmerID,
    required this.location,
    required this.cropType,
    required this.landRecordHash,
    required this.status,
    required this.activeClaimID,
  });

  // Factory constructor to parse the JSON from the Go backend
  // Note: Go/JSON uses "FarmID", "CropType", etc. (PascalCase)
  // We'll make this case-insensitive by lowercasing keys, just to be safe.
  factory Farm.fromJson(Map<String, dynamic> json) {
    // Create a new map with lowercase keys
    final Map<String, dynamic> data = {
      for (var k in json.keys) k.toLowerCase(): json[k]
    };
    
    return Farm(
      farmID: data['farmid'] ?? '',
      ownerFarmerID: data['ownerfarmerid'] ?? '',
      location: data['location'] ?? '',
      cropType: data['croptype'] ?? '',
      landRecordHash: data['landrecordhash'] ?? '',
      status: data['status'] ?? 'Unknown',
      activeClaimID: data['activeclaimid'] ?? '', 
    );
  }

  List<Map<String, dynamic>> _getCoordinates() {
    try {
      final List<dynamic> parsedJson = json.decode(location);
      return List<Map<String, dynamic>>.from(parsedJson);
    } catch (e) {
      return []; 
    }
  }

  String get latitude {
    final coords = _getCoordinates();
    if (coords.isNotEmpty) {
      return (coords.first['latitude'] ?? 0.0).toString();
    }
    return '0.0';
  }

  String get longitude {
    final coords = _getCoordinates();
    if (coords.isNotEmpty) {
      return (coords.first['longitude'] ?? 0.0).toString();
    }
    return '0.0';
  }
}
