// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, unused_local_variable

import 'dart:async'; // Add this
import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class BankDetailsPage extends StatefulWidget {
  final UserModel user;

  const BankDetailsPage({super.key, required this.user});

  @override
  State<BankDetailsPage> createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isVerifying = false;
  bool _isVerified = false;
  int _otpResendTimer = 0;

  // Simulated bank data for validation
  final Map<String, dynamic> _simulatedBankData = {
    "12345678901": {
      "name": "John Farmer",
      "ifsc": "SBIN0000123",
      "bank": "State Bank of India",
      "branch": "Main Branch"
    },
    "98765432109": {
      "name": "John Farmer",
      "ifsc": "HDFC0000456",
      "bank": "HDFC Bank",
      "branch": "City Branch"
    },
  };

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing existing bank details
    if (widget.user.bankDetail != null) {
      final bank = widget.user.bankDetail!;
      _accountHolderController.text = bank.accountHolderName;
      _accountNumberController.text = bank.accountNumber;
      _ifscCodeController.text = bank.ifscCode;
      _bankNameController.text = bank.bankName;
      _branchController.text = bank.branch;
      _isVerified = true;
    }
  }

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _isOtpSent = true;
      _otpResendTimer = 60;
    });

    // Start resend timer
    _startResendTimer();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to your registered mobile number'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startResendTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (timer) {
      if (_otpResendTimer == 0) {
        timer.cancel();
      } else {
        setState(() {
          _otpResendTimer--;
        });
      }
    });
  }

  void _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Simulate OTP verification
    await Future.delayed(const Duration(seconds: 2));

    // Check if OTP is correct (in real app, this would be API call)
    if (_otpController.text == "123456") {
      setState(() {
        _isVerifying = false;
        _isVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bank account verified successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _saveBankDetails() {
    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please verify your bank account first'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // TODO: BACKEND - Save bank details to backend
    final bankDetail = BankDetail(
      accountHolderName: _accountHolderController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      ifscCode: _ifscCodeController.text.trim(),
      bankName: _bankNameController.text.trim(),
      branch: _branchController.text.trim(),
    );

    // Navigate back
    Navigator.pop(context);
  }

  void _validateBankDetails() {
    final accountNumber = _accountNumberController.text.trim();

    // Simulate bank details validation
    if (_simulatedBankData.containsKey(accountNumber)) {
      final bankData = _simulatedBankData[accountNumber]!;
      if (bankData["name"] == _accountHolderController.text.trim()) {
        setState(() {
          _ifscCodeController.text = bankData["ifsc"];
          _bankNameController.text = bankData["bank"];
          _branchController.text = bankData["branch"];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account holder name does not match bank records'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Bank Details',
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Verification Status
              if (_isVerified) _buildVerificationSuccess(),

              // Account Holder Name
              _buildFormField(
                controller: _accountHolderController,
                label: 'Account Holder Name',
                hintText: 'Enter account holder name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Account Number
              _buildFormField(
                controller: _accountNumberController,
                label: 'Account Number',
                hintText: 'Enter bank account number',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.length == 11) {
                    // Simulated validation trigger
                    _validateBankDetails();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  if (value.length < 9 || value.length > 18) {
                    return 'Please enter a valid account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // IFSC Code
              _buildFormField(
                controller: _ifscCodeController,
                label: 'IFSC Code',
                hintText: 'Enter IFSC code',
                icon: Icons.code,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IFSC code';
                  }
                  if (value.length != 11) {
                    return 'IFSC code must be 11 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bank Name
              _buildFormField(
                controller: _bankNameController,
                label: 'Bank Name',
                hintText: 'Enter bank name',
                icon: Icons.account_balance,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Branch
              _buildFormField(
                controller: _branchController,
                label: 'Branch',
                hintText: 'Enter branch name',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter branch name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // OTP Section
              if (_isOtpSent && !_isVerified) _buildOtpSection(),

              // Action Buttons
              if (!_isVerified) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _isLoading
                      ? ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Sending OTP...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Send OTP for Verification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  'OTP will be sent to your registered mobile number for verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],

              // Save Button (only when verified)
              if (_isVerified) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveBankDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationSuccess() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Account Verified',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Your bank account has been successfully verified',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
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
            onChanged: onChanged,
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

  Widget _buildOtpSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.sms_outlined, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              letterSpacing: 8,
            ),
            maxLength: 6,
            decoration: InputDecoration(
              hintText: '000000',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[500]!),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: _isVerifying
                      ? ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Verifying...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Verify OTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              _otpResendTimer > 0
                  ? Text(
                      'Resend in $_otpResendTimer s',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : TextButton(
                      onPressed: _sendOtp,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit OTP sent to your registered mobile number',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
