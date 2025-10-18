// ignore_for_file: prefer_const_constructors, unused_element

import '../auth/login_page.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'land_details_page.dart';
import 'bank_details_page.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 30),

            // Profile Completion - Only show if not complete
            if (!user.isProfileComplete) ...[
              _buildProfileCompletion(),
              const SizedBox(height: 30),
            ],

            // Personal Information
            _buildPersonalInfoSection(),
            const SizedBox(height: 30),

            // Land Details
            _buildLandDetailsSection(context),
            const SizedBox(height: 30),

            // Bank Details
            _buildBankDetailsSection(context),
            const SizedBox(height: 30),

            // Actions
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.green[100],
            child: Icon(Icons.person, size: 50, color: Colors.green[800]),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phoneNumber ?? "Phone not added",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.green),
            onPressed: () {
              // TODO: Navigate to personal info edit page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profile Completion",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                "${(user.completionPercentage * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: user.completionPercentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            "Complete your profile to unlock all features",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit, size: 20, color: Colors.green),
                onPressed: () {
                  // TODO: Navigate to personal info edit page
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Aadhar Number", user.aadharNumber ?? "Not added"),
          _buildInfoRow("Date of Birth", user.dateOfBirth ?? "Not added"),
          _buildInfoRow("Address", user.address ?? "Not added"),
        ],
      ),
    );
  }

  Widget _buildLandDetailsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.landscape_outlined, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                "Land Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: user.landDetails.isEmpty
                    ? Icon(Icons.add_circle_outline,
                        size: 20, color: Colors.green)
                    : Icon(Icons.edit, size: 20, color: Colors.green),
                onPressed: () {
                  _navigateToLandDetails(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user.landDetails.isEmpty)
            _buildEmptyState(
              icon: Icons.landscape_outlined,
              message: "No land details added",
              buttonText: "Add Land Details",
              onPressed: () {
                _navigateToLandDetails(context);
              },
            )
          else
            ...user.landDetails
                .map((land) => _buildLandCard(land, context))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildBankDetailsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_outlined, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                "Bank Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: user.bankDetail == null
                    ? Icon(Icons.add_circle_outline,
                        size: 20, color: Colors.green)
                    : Icon(Icons.edit, size: 20, color: Colors.green),
                onPressed: () {
                  _navigateToBankDetails(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user.bankDetail == null)
            _buildEmptyState(
              icon: Icons.account_balance_outlined,
              message: "No bank details added",
              buttonText: "Add Bank Details",
              onPressed: () {
                _navigateToBankDetails(context);
              },
            )
          else
            _buildBankInfo(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Edit profile functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.edit, color: Colors.white),
            label: Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.red),
            ),
            icon: Icon(Icons.logout, color: Colors.red),
            label: Text(
              "Logout",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    // TODO: BACKEND - Clear user session/token
    // TODO: BACKEND - Call logout API

    // Navigate to login page and remove all routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // Navigation to LandDetailsPage
  void _navigateToLandDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandDetailsPage(user: user),
      ),
    );
  }

  // New method for Bank Details navigation
  void _navigateToBankDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankDetailsPage(user: user),
      ),
    );
  }

  Widget _buildLandCard(LandDetail land, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToLandDetails(context);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.numbers, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  "Survey No: ${land.surveyNumber}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
                const Spacer(),
                Text(
                  land.area,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              land.location,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(land.soilType),
                  backgroundColor: Colors.orange[50],
                  labelStyle: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 4,
                  children: land.crops
                      .map((crop) => Chip(
                            label: Text(crop),
                            backgroundColor: Colors.green[50],
                            labelStyle: TextStyle(
                              color: Colors.green[800],
                              fontSize: 10,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo() {
    final bank = user.bankDetail!;
    return Column(
      children: [
        _buildInfoRowWithVerification("Account Number",
            "XXXX XXXX XXXX ${bank.accountNumber.substring(bank.accountNumber.length - 4)}"),
        _buildInfoRowWithVerification("IFSC Code", bank.ifscCode),
        _buildInfoRowWithVerification("Bank Name", bank.bankName),
        _buildInfoRowWithVerification("Branch", bank.branch),
        _buildInfoRowWithVerification("Account Holder", bank.accountHolderName),
        _buildInfoRowWithVerification("Status", "Verified", isVerified: true),
      ],
    );
  }

  // Original _buildInfoRow method (without verification)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color:
                    value == "Not added" ? Colors.grey[400] : Colors.grey[600],
                fontStyle:
                    value == "Not added" ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New method for info rows with verification status
  Widget _buildInfoRowWithVerification(String label, String value,
      {bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: value == "Not added"
                        ? Colors.grey[400]
                        : isVerified
                            ? Colors.green
                            : Colors.grey[600],
                    fontStyle: value == "Not added"
                        ? FontStyle.italic
                        : FontStyle.normal,
                    fontWeight:
                        isVerified ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (isVerified) ...[
                  SizedBox(width: 8),
                  Icon(Icons.verified, color: Colors.green, size: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
