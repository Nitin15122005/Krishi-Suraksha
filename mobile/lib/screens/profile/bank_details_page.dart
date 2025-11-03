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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // ... (same app bar styling as before)
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Bank Details', style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<BankDetails?>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Once loaded, build the form
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormField(
                    controller: _accountHolderController,
                    label: 'Account Holder Name',
                    hintText: 'Enter account holder name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter account holder name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    controller: _accountNumberController,
                    label: 'Account Number',
                    hintText: 'Enter bank account number',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter account number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    controller: _ifscCodeController,
                    label: 'IFSC Code',
                    hintText: 'Enter IFSC code',
                    icon: Icons.code,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter IFSC code';
                      if (value.length != 11) return 'IFSC code must be 11 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    controller: _bankNameController,
                    label: 'Bank Name',
                    hintText: 'Enter bank name',
                    icon: Icons.account_balance,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter bank name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // --- Save Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveBankDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text(
                              'Save Bank Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
    );
  }

  // --- Using your friend's nice form field builder ---
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
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.green),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}