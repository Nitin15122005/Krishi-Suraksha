class UserModel {
  final String farmerId; // Changed from id to farmerId
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final DateTime? createdAt;
  final String? aadharNumber;
  final String? address;
  final List<FarmModel> farms; // Changed from landDetails to farms
  final BankDetail? bankDetail;
  final bool isPhoneVerified; // Added verification status
  final bool isAadhaarVerified; // Added verification status

  UserModel({
    required this.farmerId,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.createdAt,
    this.aadharNumber,
    this.address,
    this.farms = const [],
    this.bankDetail,
    this.isPhoneVerified = false,
    this.isAadhaarVerified = false,
  });

  // Helper getters for profile completion
  bool get isProfileComplete {
    return phoneNumber != null &&
        aadharNumber != null &&
        address != null &&
        farms.isNotEmpty &&
        bankDetail != null &&
        isPhoneVerified &&
        isAadhaarVerified;
  }

  double get completionPercentage {
    int completedFields = 2; // name and email are always there
    if (phoneNumber != null) completedFields++;
    if (aadharNumber != null) completedFields++;
    if (address != null) completedFields++;
    if (farms.isNotEmpty) completedFields++;
    if (bankDetail != null) completedFields++;
    if (isPhoneVerified) completedFields++;
    if (isAadhaarVerified) completedFields++;

    return completedFields / 8.0; // Total 8 fields to complete
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      farmerId: json['farmerId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      aadharNumber: json['aadharNumber'],
      address: json['address'],
      farms: (json['farms'] as List?)
              ?.map((e) => FarmModel.fromJson(e))
              .toList() ??
          [],
      bankDetail: json['bankDetail'] != null
          ? BankDetail.fromJson(json['bankDetail'])
          : null,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isAadhaarVerified: json['isAadhaarVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmerId': farmerId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
      'aadharNumber': aadharNumber,
      'address': address,
      'farms': farms.map((e) => e.toJson()).toList(),
      'bankDetail': bankDetail?.toJson(),
      'isPhoneVerified': isPhoneVerified,
      'isAadhaarVerified': isAadhaarVerified,
    };
  }

  UserModel copyWith({
    String? farmerId,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImage,
    DateTime? createdAt,
    String? aadharNumber,
    String? address,
    List<FarmModel>? farms,
    BankDetail? bankDetail,
    bool? isPhoneVerified,
    bool? isAadhaarVerified,
  }) {
    return UserModel(
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      address: address ?? this.address,
      farms: farms ?? this.farms,
      bankDetail: bankDetail ?? this.bankDetail,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isAadhaarVerified: isAadhaarVerified ?? this.isAadhaarVerified,
    );
  }
}

class FarmModel {
  final String farmId;
  final String ownerFarmerId;
  final String location; // "lat:19.0760,lon:72.8777" format
  final String cropType;
  final double area; // Changed from String to double
  final String? description;
  final String? landRecordHash; // SHA-256 hash of 7-12 doc
  final String? activeClaimId;
  final DateTime? createdAt;

  FarmModel({
    required this.farmId,
    required this.ownerFarmerId,
    required this.location,
    required this.cropType,
    required this.area,
    this.description,
    this.landRecordHash,
    this.activeClaimId,
    this.createdAt,
  });

  // Helper method to get latitude and longitude
  double? get latitude {
    try {
      final parts = location.split(',');
      if (parts.length == 2) {
        final latPart = parts[0].split(':')[1];
        return double.tryParse(latPart);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double? get longitude {
    try {
      final parts = location.split(',');
      if (parts.length == 2) {
        final lonPart = parts[1].split(':')[1];
        return double.tryParse(lonPart);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      farmId: json['farmId'] ?? '',
      ownerFarmerId: json['ownerFarmerId'] ?? '',
      location: json['location'] ?? '',
      cropType: json['cropType'] ?? '',
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      landRecordHash: json['landRecordHash'],
      activeClaimId: json['activeClaimId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmId': farmId,
      'ownerFarmerId': ownerFarmerId,
      'location': location,
      'cropType': cropType,
      'area': area,
      'description': description,
      'landRecordHash': landRecordHash,
      'activeClaimId': activeClaimId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class BankDetail {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branch;

  BankDetail({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branch,
  });

  factory BankDetail.fromJson(Map<String, dynamic> json) {
    return BankDetail(
      accountHolderName: json['accountHolderName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      bankName: json['bankName'] ?? '',
      branch: json['branch'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'branch': branch,
    };
  }
}

// Claim Model for claim-related data
class ClaimModel {
  final String claimId;
  final String farmId;
  final String farmerId;
  final String reason;
  final String status; // "Pending", "Approved", "Rejected", "Human_Review"
  final double damagePercentage; // from satellite analysis
  final double payoutAmount; // calculated or approved
  final String? satelliteDataHash; // hash of Python output summary
  final String? assignedAuditor;
  final String? rejectionReason;
  final DateTime? createdAt;
  final List<String>? evidenceImages; // URLs from Firebase Storage
  final String? auditorNotes;

  ClaimModel({
    required this.claimId,
    required this.farmId,
    required this.farmerId,
    required this.reason,
    required this.status,
    required this.damagePercentage,
    required this.payoutAmount,
    this.satelliteDataHash,
    this.assignedAuditor,
    this.rejectionReason,
    this.createdAt,
    this.evidenceImages,
    this.auditorNotes,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      claimId: json['claimId'] ?? '',
      farmId: json['farmId'] ?? '',
      farmerId: json['farmerId'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      damagePercentage: (json['damagePercentage'] as num?)?.toDouble() ?? 0.0,
      payoutAmount: (json['payoutAmount'] as num?)?.toDouble() ?? 0.0,
      satelliteDataHash: json['satelliteDataHash'],
      assignedAuditor: json['assignedAuditor'],
      rejectionReason: json['rejectionReason'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      evidenceImages: List<String>.from(json['evidenceImages'] ?? []),
      auditorNotes: json['auditorNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'claimId': claimId,
      'farmId': farmId,
      'farmerId': farmerId,
      'reason': reason,
      'status': status,
      'damagePercentage': damagePercentage,
      'payoutAmount': payoutAmount,
      'satelliteDataHash': satelliteDataHash,
      'assignedAuditor': assignedAuditor,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt?.toIso8601String(),
      'evidenceImages': evidenceImages,
      'auditorNotes': auditorNotes,
    };
  }
}
