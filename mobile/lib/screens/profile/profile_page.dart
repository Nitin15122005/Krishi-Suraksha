import 'package:agri_claim_mobile/screens/auth/login_page.dart';
import 'package:agri_claim_mobile/screens/dashboard/farms_page.dart'; 
import 'package:agri_claim_mobile/models/bank_details_model.dart';
import 'package:agri_claim_mobile/services/api_service.dart';
import 'package:agri_claim_mobile/services/storage_service.dart';
import 'bank_details_page.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  body: Container(
//     decoration: BoxDecoration(  
//   image: const DecorationImage(
//     image: AssetImage('assets/image/Background.png'),
//     fit: BoxFit.cover,
    
//     opacity:0,
//   ),
// ),
      child: SingleChildScrollView(
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
    ),
    );
  }
  BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  );
}

Widget _buildProfileHeader() {
  return Container(
    margin: const EdgeInsets.only( top: 64),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // 🔹 Profile Image
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 36,
            // backgroundImage: const AssetImage('assets/farmer.jpg'),
            backgroundColor: Colors.grey[200],
          ),
        ),

        const SizedBox(width: 16),

        // 🔹 Text Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Name
              Text(
                _farmerName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173300),
                ),
              ),

              const SizedBox(height: 6),

              // ID
              Text(
                "#$_farmerID",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // 🔹 Optional Edit Icon (modern touch)
        
      ],
    ),
  );
}

Widget _buildPersonalInfoSection() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 255, 255, 255),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 🔹 Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Personal Information",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF173300),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 🔹 Farmer ID
        _buildInfoItem(
          icon: Icons.tag,
          label: "Farmer ID",
          value: _farmerID,
        ),

        const Divider(height: 22, thickness: 0.8),

        // 🔹 Mobile
        _buildInfoItem(
          icon: Icons.phone_android,
          label: "Mobile Number",
          value: _mobile,
        ),

        const Divider(height: 22, thickness: 0.8),

        // 🔹 Address
        _buildInfoItem(
          icon: Icons.location_on_outlined,
          label: "Address",
          value: _address,
          maxLines: 3,
        ),
      ],
    ),
  );
}

Widget _buildInfoItem({
  required IconData icon,
  required String label,
  required String value,
  int maxLines = 1,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      
      // Left Icon
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
      ),

      const SizedBox(width: 12),

      // Text Content
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 4),

            // Value
            Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1B1B1B),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
  Widget _buildFarmDetailsSection(BuildContext context) {
    return Container(
  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: const Color(0xFFE5F2DA),
  
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Top Row (Icon + Title)
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
             
            ),
            child: Icon(Icons.eco_outlined, color: Color(0xFF173300)),
          ),
          const SizedBox(width: 12),
          Text(
            "Farm Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173300),
            ),
          ),
        ],
      ),

      const SizedBox(height: 10),

      // Subtitle
      Text(
        "View and manage your registered farms",
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
        ),
      ),

      const SizedBox(height: 16),

      // Button
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FarmsPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0XFF000000)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Manage Farms",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    ],
  ),

    );
  }

 Widget _buildBankDetailsSection(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 255, 255, 255),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 🔹 Header Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.creditCard,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Bank Details",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B1B1B),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Color(0xFF2E7D32)),
              onPressed: () async {
                final result = await showModalBottomSheet(
  context: context,
  isScrollControlled: true, // IMPORTANT for full height
  backgroundColor: Colors.transparent,
  builder: (context) => const BankDetailsPage(),
);

if (result == true) {
  _loadBankDetails();
}

              
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 🔹 Content
        FutureBuilder<BankDetails?>(
          future: _bankDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Could not load bank details.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final bankDetails = snapshot.data;

            if (bankDetails == null) {
              return _buildPremiumEmptyState(context);
            } else {
              return _buildBankInfo(bankDetails);
            }
          },
        ),
      ],
    ),
  );
}

Widget _buildPremiumEmptyState(BuildContext context) {
  return Center(
  child: Column(
    children: [
      const SizedBox(height: 10),

      // Icon circle
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF5E4),
          shape: BoxShape.circle,
        ),
        child: const Icon(
         LucideIcons.building,
          size: 32,
          color: Color(0xFF4CAF50),
        ),
      ),

      const SizedBox(height: 12),

      // Text
      const Text(
        "No bank details added yet",
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 14),

      // Button
      ElevatedButton(
        onPressed: () async {
          final result = await showModalBottomSheet(
  context: context,
  isScrollControlled: true, // IMPORTANT for full height
  backgroundColor: Colors.transparent,
  builder: (context) => const BankDetailsPage(),
);

if (result == true) {
  _loadBankDetails();
}
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA9E981),
          foregroundColor: Colors.black,
          elevation: 0, 
  shadowColor: Colors.transparent, 
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "Add Bank Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      const SizedBox(height: 6),
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
               backgroundColor: const Color.fromARGB(255, 239, 112, 103),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
               side: BorderSide(color: const Color.fromARGB(255, 239, 112, 103)),
              
            ),
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text("Logout", style: TextStyle(color: Colors.white)),
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
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFF9FE970).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF173300),
            ),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
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
