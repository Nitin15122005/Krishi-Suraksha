import 'package:agri_claim_mobile/models/bank_details_model.dart';
import 'package:agri_claim_mobile/services/api_service.dart';
import 'package:flutter/material.dart';

class BankDetailsPage extends StatefulWidget {
  const BankDetailsPage({super.key});

  @override
  State<BankDetailsPage> createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Text Controllers
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();

  // Page State
  late Future<BankDetails?> _detailsFuture;
  bool _isLoading = false; // For the save button

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadBankDetails();
  }

  // Fetches details and pre-fills the form
  Future<BankDetails?> _loadBankDetails() async {
    try {
      final details = await _apiService.getBankDetails();
      if (details != null) {
        _accountHolderController.text = details.accountHolderName;
        _accountNumberController.text = details.accountNumber;
        _ifscCodeController.text = details.ifscCode;
        _bankNameController.text = details.bankName;
      }
      return details;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading details: $e'), backgroundColor: Colors.red),
      );
      return null;
    }
  }

  // Saves the form data to the backend
  void _saveBankDetails() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    setState(() => _isLoading = true);

    try {
      final bankDetails = BankDetails(
        accountHolderName: _accountHolderController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscCodeController.text.trim(),
        bankName: _bankNameController.text.trim(),
      );

      await _apiService.saveBankDetails(bankDetails);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bank details saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Pop and signal a refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving details: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.65,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(
      children: [

        // 🔹 Handle
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),

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
                Icons.account_balance_outlined,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Bank Details",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF173300),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 🔹 Form
        Expanded(
          child: FutureBuilder<BankDetails?>(
            future: _detailsFuture,
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      _buildFormField(
                        controller: _accountHolderController,
                        label: 'Account Holder Name',
                        hintText: 'Enter account holder name',
                        icon: Icons.person_outline,
                        validator: (value) =>
                            value!.isEmpty ? 'Required field' : null,
                      ),

                      const SizedBox(height: 18),

                      _buildFormField(
                        controller: _accountNumberController,
                        label: 'Account Number',
                        hintText: 'Enter account number',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Required field' : null,
                      ),

                      const SizedBox(height: 18),

                      _buildFormField(
                        controller: _ifscCodeController,
                        label: 'IFSC Code',
                        hintText: 'Enter IFSC code',
                        icon: Icons.code,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required field';
                          }
                          if (value.length != 11) {
                            return 'Invalid IFSC';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      _buildFormField(
                        controller: _bankNameController,
                        label: 'Bank Name',
                        hintText: 'Enter bank name',
                        icon: Icons.account_balance,
                        validator: (value) =>
                            value!.isEmpty ? 'Required field' : null,
                      ),

                      const SizedBox(height: 28),

                      // 🔥 MATCHED BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveBankDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA9E981),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  'Save Bank Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}// --- Using your friend's nice form field builder ---
  Widget _buildFormField({
  required TextEditingController controller,
  required String label,
  required String hintText,
  required IconData icon,
  required String? Function(String?) validator,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // 🔹 Label
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),

      const SizedBox(height: 6),

      // 🔹 Input Card
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,

            // 🔥 ICON STYLE MATCHED
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: const Color(0xFF2E7D32),
              ),
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ),
    ],
  );
}
}