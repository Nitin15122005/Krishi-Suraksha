class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final DateTime? createdAt;
  final String? aadharNumber;
  final String? dateOfBirth;
  final String? address;
  final List<LandDetail> landDetails;
  final BankDetail? bankDetail;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.createdAt,
    this.aadharNumber,
    this.dateOfBirth,
    this.address,
    this.landDetails = const [],
    this.bankDetail,
  });

  // Helper getters for profile completion
  bool get isProfileComplete {
    return phoneNumber != null &&
        aadharNumber != null &&
        address != null &&
        landDetails.isNotEmpty &&
        bankDetail != null;
  }

  double get completionPercentage {
    int completedFields = 1; // name and email are always there
    if (phoneNumber != null) completedFields++;
    if (aadharNumber != null) completedFields++;
    if (address != null) completedFields++;
    if (landDetails.isNotEmpty) completedFields++;
    if (bankDetail != null) completedFields++;

    return completedFields / 6.0; // Total 6 fields to complete
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      aadharNumber: json['aadharNumber'],
      dateOfBirth: json['dateOfBirth'],
      address: json['address'],
      landDetails: (json['landDetails'] as List?)
              ?.map((e) => LandDetail.fromJson(e))
              .toList() ??
          [],
      bankDetail: json['bankDetail'] != null
          ? BankDetail.fromJson(json['bankDetail'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
      'aadharNumber': aadharNumber,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'landDetails': landDetails.map((e) => e.toJson()).toList(),
      'bankDetail': bankDetail?.toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImage,
    DateTime? createdAt,
    String? aadharNumber,
    String? dateOfBirth,
    String? address,
    List<LandDetail>? landDetails,
    BankDetail? bankDetail,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      landDetails: landDetails ?? this.landDetails,
      bankDetail: bankDetail ?? this.bankDetail,
    );
  }
}

class LandDetail {
  final String surveyNumber;
  final String area;
  final String location;
  final String soilType;
  final List<String> crops;

  LandDetail({
    required this.surveyNumber,
    required this.area,
    required this.location,
    required this.soilType,
    required this.crops,
  });

  factory LandDetail.fromJson(Map<String, dynamic> json) {
    return LandDetail(
      surveyNumber: json['surveyNumber'] ?? '',
      area: json['area'] ?? '',
      location: json['location'] ?? '',
      soilType: json['soilType'] ?? '',
      crops: List<String>.from(json['crops'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surveyNumber': surveyNumber,
      'area': area,
      'location': location,
      'soilType': soilType,
      'crops': crops,
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
