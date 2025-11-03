import 'package:agri_claim_mobile/screens/auth/login_page.dart';
import 'package:agri_claim_mobile/screens/farm/farms_page.dart'; 
import 'package:agri_claim_mobile/models/bank_details_model.dart';
import 'package:agri_claim_mobile/services/api_service.dart';
import 'package:agri_claim_mobile/services/storage_service.dart';
import 'bank_details_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();

  // State variables for profile data
  String _farmerName = 'Loading...';
  String _farmerID = 'Loading...';
  String _mobile = 'Loading...';
  String _address = 'Loading...';
  
  // Future for bank details
  late Future<BankDetails?> _bankDetailsFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadBankDetails();
  }

  void _loadProfileData() async {
    _farmerName = await _storageService.getFarmerName() ?? 'N/A';
    _farmerID = await _storageService.getFarmerID() ?? 'N/A';
    _mobile = await _storageService.getFarmerMobile() ?? 'N/A';
    _address = await _storageService.getFarmerAddress() ?? 'N/A';
    setState(() {}); 
  }

  void _loadBankDetails() {
    _bankDetailsFuture = _apiService.getBankDetails();
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),

            _buildPersonalInfoSection(),
            const SizedBox(height: 30),
            _buildFarmDetailsSection(context),
            const SizedBox(height: 30),
            _buildBankDetailsSection(context), 
            const SizedBox(height: 30),
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
                  _farmerName, // From state
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[900]),
                ),
                const SizedBox(height: 8),
                Text(
                  _mobile, // From state
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  "Farmer ID: $_farmerID", // From state
                  style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w500),
                ),
              ],
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Farmer ID", _farmerID),
          _buildInfoRow("Mobile", _mobile),
          _buildInfoRow("Address", _address, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildFarmDetailsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: ListTile(
        leading: Icon(Icons.agriculture_outlined, color: Colors.green),
        title: Text(
          "Farm Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        subtitle: Text("View and manage your registered farms"),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to the FarmsPage we already built
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FarmsPage()),
          );
        },
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
              Text("Bank Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit, size: 20, color: Colors.green),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankDetailsPage(),
                    ),
                  );

                  if (result == true) {
                    _loadBankDetails(); // This re-runs the FutureBuilder
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // --- Use FutureBuilder to show Bank Info ---
          FutureBuilder<BankDetails?>(
            future: _bankDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return const Center(child: Text('Could not load bank details.', style: TextStyle(color: Colors.red)));
              }

              final bankDetails = snapshot.data;

              if (bankDetails == null) {
                return _buildEmptyState(
                  icon: Icons.account_balance_outlined,
                  message: "No bank details added",
                  buttonText: "Add Bank Details",
                  onPressed: () {
                    // TODO: Navigate to BankDetailsPage
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Building this page next!'))
                    );
                  },
                );
              } else {
                return _buildBankInfo(bankDetails);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _showLogoutConfirmation(context),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.red),
            ),
            icon: Icon(Icons.logout, color: Colors.red),
            label: Text("Logout", style: TextStyle(color: Colors.red)),
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
            TextButton(onPressed: () {
                Navigator.pop(context); // Close the dialog
                _logout(context); // Call the logout function
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    await _storageService.clearSession();

    // Navigate to login page and remove all routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // navogateToLandDetails
//  void _navigateToLandDetails(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LandDetailsPage(user: user),
//       ),
//     );
//   }

  Widget _buildBankInfo(BankDetails bank) {
    // Mask the account number
    String maskedAccount = "XXXX XXXX " + (bank.accountNumber.length > 4 
      ? bank.accountNumber.substring(bank.accountNumber.length - 4)
      : bank.accountNumber);

    return Column(
      children: [
        _buildInfoRow("Account Holder", bank.accountHolderName),
        _buildInfoRow("Account Number", maskedAccount),
        _buildInfoRow("IFSC Code", bank.ifscCode),
        _buildInfoRow("Bank Name", bank.bankName),
        _buildInfoRowWithVerification("Status", "Verified", isVerified: true),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: value == "N/A" ? Colors.grey[400] : Colors.grey[600]),
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }

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
                            : Colors.orange,
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
