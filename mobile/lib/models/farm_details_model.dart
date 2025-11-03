class FarmDetails {
  final String farmID;
  final String ownerFarmerID;
  final String location;
  final String cropType;
  final String landRecordHash;
  final String status;
  final String activeClaimID;
  final String landRecordFileURL; // The new field from your Go handler

  FarmDetails({
    required this.farmID,
    required this.ownerFarmerID,
    required this.location,
    required this.cropType,
    required this.landRecordHash,
    required this.status,
    required this.activeClaimID,
    required this.landRecordFileURL, // Added
  });

  // Factory constructor to parse the JSON from the Go backend
  factory FarmDetails.fromJson(Map<String, dynamic> json) {
    // This assumes your Go handler returns a single, flat JSON object
    return FarmDetails(
      farmID: json['farmID'] ?? '',
      ownerFarmerID: json['ownerFarmerID'] ?? '',
      location: json['location'] ?? '',
      cropType: json['cropType'] ?? '',
      landRecordHash: json['landRecordHash'] ?? '',
      status: json['status'] ?? 'Unknown',
      activeClaimID: json['activeClaimID'] ?? '',
      landRecordFileURL: json['landRecordFileURL'] ?? '', // Added
    );
  }
}