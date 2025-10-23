// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import '../dashboard/dashboard_page.dart';
import 'package:agri_claim_mobile/services/firebase_service.dart';
import 'package:agri_claim_mobile/services/otp_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  final _aadhaarOtpController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPhoneVerified = false;
  bool _isAadhaarVerified = false;
  bool _showPhoneOtpField = false;
  bool _showAadhaarOtpField = false;
  bool _isSendingPhoneOtp = false;
  bool _isSendingAadhaarOtp = false;
  bool _isVerifyingPhoneOtp = false;
  bool _isVerifyingAadhaarOtp = false;
  bool _showVerificationWarning = false;
  bool _isCreatingAccount = false;

  // New state variables for duplicate checking
  bool _isCheckingPhone = false;
  bool _isCheckingAadhaar = false;
  bool _phoneExists = false;
  bool _aadhaarExists = false;

  final FirebaseService _firebaseService = FirebaseService();
  final OtpService _otpService = OtpService();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    _aadhaarController.addListener(_onAadhaarChanged);
  }

  void _onPhoneChanged() {
    if (_phoneController.text.length == 10) {
      _checkPhoneExists();
    } else {
      setState(() {
        _phoneExists = false;
        _isPhoneVerified = false;
        _showPhoneOtpField = false;
      });
    }
  }

  void _onAadhaarChanged() {
    if (_aadhaarController.text.length == 12) {
      _checkAadhaarExists();
    } else {
      setState(() {
        _aadhaarExists = false;
        _isAadhaarVerified = false;
        _showAadhaarOtpField = false;
      });
    }
  }

  Future<void> _checkPhoneExists() async {
    setState(() {
      _isCheckingPhone = true;
    });

    final exists =
        await _firebaseService.isPhoneNumberExists(_phoneController.text);

    setState(() {
      _isCheckingPhone = false;
      _phoneExists = exists;
    });
  }

  Future<void> _checkAadhaarExists() async {
    setState(() {
      _isCheckingAadhaar = true;
    });

    final exists =
        await _firebaseService.isAadhaarNumberExists(_aadhaarController.text);

    setState(() {
      _isCheckingAadhaar = false;
      _aadhaarExists = exists;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _aadhaarController.dispose();
    _phoneOtpController.dispose();
    _aadhaarOtpController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isPhoneVerified || !_isAadhaarVerified) {
        setState(() {
          _showVerificationWarning = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please verify both phone number and Aadhaar number first',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isCreatingAccount = true;
      });

      // Prepare farmer data for blockchain and Firebase
      Map<String, dynamic> farmerData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'name': '${_firstNameController.text} ${_lastNameController.text}',
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'address': _addressController.text,
        'aadhaarNumber': _aadhaarController.text,
        'isPhoneVerified': _isPhoneVerified,
        'isAadhaarVerified': _isAadhaarVerified,
        'farmerId': _generateFarmerId(), // Generate temporary ID
      };

      await _registerFarmer(farmerData);
    }
  }

  String _generateFarmerId() {
    // Generate a unique FarmerID (in production, this should come from backend/blockchain)
    return 'FARM${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _registerFarmer(Map<String, dynamic> farmerData) async {
    try {
      // TODO: BACKEND - Replace with actual blockchain API call
      // 1. Store in Blockchain: FarmerID, Name, FarmIDs array, Timestamp
      // 2. Get the actual FarmerID from blockchain response

      // Simulate blockchain registration
      await Future.delayed(Duration(seconds: 2));

      // Store in Firebase with password
      await _firebaseService.createUser({
        'farmerId': farmerData['farmerId'],
        'name': farmerData['name'],
        'phone': farmerData['phone'],
        'password': farmerData['password'], // Make sure password is included
        'address': farmerData['address'],
        'aadhaarNumber': farmerData['aadhaarNumber'],
        'isPhoneVerified': farmerData['isPhoneVerified'],
        'isAadhaarVerified': farmerData['isAadhaarVerified'],
      });

      _navigateToDashboard();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isCreatingAccount = false;
      });
    }
  }

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
      (route) => false,
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _sendPhoneOtp() async {
    if (_phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_phoneExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This phone number is already registered'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSendingPhoneOtp = true;
    });

    try {
      final otp = _otpService.generateOtp();
      final success = await _otpService.sendOtp(_phoneController.text, otp);

      if (success) {
        // Store OTP in Firebase for verification
        await _firebaseService.storeOtpData(
            _phoneController.text, otp, 'phone');

        setState(() {
          _isSendingPhoneOtp = false;
          _showPhoneOtpField = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to ${_phoneController.text}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      setState(() {
        _isSendingPhoneOtp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _verifyPhoneOtp() async {
    if (_phoneOtpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter OTP'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isVerifyingPhoneOtp = true;
    });

    try {
      final isValid = await _firebaseService.verifyOtp(
          _phoneController.text, _phoneOtpController.text);

      if (isValid) {
        setState(() {
          _isVerifyingPhoneOtp = false;
          _isPhoneVerified = true;
          _showPhoneOtpField = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number verified successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      setState(() {
        _isVerifyingPhoneOtp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP verification failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _sendAadhaarOtp() async {
    if (_aadhaarController.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid 12-digit Aadhaar number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_aadhaarExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This Aadhaar number is already registered'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSendingAadhaarOtp = true;
    });

    try {
      final otp = _otpService.generateOtp();
      final success = await _otpService.sendAadhaarOtp(_aadhaarController.text);

      if (success) {
        // Store OTP in Firebase for verification
        await _firebaseService.storeOtpData(
            _aadhaarController.text, otp, 'aadhaar');

        setState(() {
          _isSendingAadhaarOtp = false;
          _showAadhaarOtpField = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aadhaar OTP sent to registered mobile'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Failed to send Aadhaar OTP');
      }
    } catch (e) {
      setState(() {
        _isSendingAadhaarOtp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send Aadhaar OTP: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _verifyAadhaarOtp() async {
    if (_aadhaarOtpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter Aadhaar OTP'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isVerifyingAadhaarOtp = true;
    });

    try {
      final isValid = await _firebaseService.verifyOtp(
          _aadhaarController.text, _aadhaarOtpController.text);

      if (isValid) {
        setState(() {
          _isVerifyingAadhaarOtp = false;
          _isAadhaarVerified = true;
          _showAadhaarOtpField = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aadhaar verified successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Invalid Aadhaar OTP');
      }
    } catch (e) {
      setState(() {
        _isVerifyingAadhaarOtp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aadhaar OTP verification failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Helper method to get phone icon color
  Color _getPhoneIconColor() {
    if (_isPhoneVerified) return Colors.green;
    if (_phoneExists) return Colors.red;
    return Colors.green.shade700;
  }

  // Helper method to get aadhaar icon color
  Color _getAadhaarIconColor() {
    if (_isAadhaarVerified) return Colors.green;
    if (_aadhaarExists) return Colors.red;
    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Header Section
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Agri-Claim',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(2, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your farmer account',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(1, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Signup Form
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // First Name
                            _buildFormField(
                              controller: _firstNameController,
                              hintText: 'First Name',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Last Name
                            _buildFormField(
                              controller: _lastNameController,
                              hintText: 'Last Name',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Phone Number with Verification - SIMPLIFIED VERSION
                            _buildPhoneVerificationField(),
                            SizedBox(height: 8),

                            // Phone OTP Field
                            if (_showPhoneOtpField && !_isPhoneVerified)
                              _buildPhoneOtpField(),
                            SizedBox(height: 16),

                            // Aadhaar Number with Verification - SIMPLIFIED VERSION
                            _buildAadhaarVerificationField(),
                            SizedBox(height: 8),

                            // Aadhaar OTP Field
                            if (_showAadhaarOtpField && !_isAadhaarVerified)
                              _buildAadhaarOtpField(),
                            SizedBox(height: 16),

                            // Address
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                controller: _addressController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Full Address',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.home_outlined,
                                    color: Colors.green.shade700,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 16),

                            // Password
                            _buildPasswordField(
                              controller: _passwordController,
                              hintText: 'Password',
                              isPasswordVisible: _isPasswordVisible,
                              onToggleVisibility: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Confirm Password
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Password',
                              isPasswordVisible: _isConfirmPasswordVisible,
                              onToggleVisibility: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),

                            // Verification Status - Only show when user tries to submit without verification
                            if (_showVerificationWarning)
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Please verify both phone number and Aadhaar to continue',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_showVerificationWarning) SizedBox(height: 16),

                            // Create Account Button with Loading State
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: _isCreatingAccount
                                  ? ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700
                                            .withOpacity(0.6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
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
                                            'Creating Account...',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: (_isPhoneVerified &&
                                                _isAadhaarVerified)
                                            ? Colors.green.shade700
                                            : Colors.green.shade700
                                                .withOpacity(0.6),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 5,
                                        shadowColor:
                                            Colors.black.withOpacity(0.3),
                                      ),
                                      child: Text(
                                        'Create Account',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 16),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        offset: Offset(1, 1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _navigateToLogin,
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.green.shade300,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: Offset(1, 1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Simplified phone verification field
  Widget _buildPhoneVerificationField() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border:
                _phoneExists ? Border.all(color: Colors.red, width: 1) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_isPhoneVerified,
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon:
                        Icon(Icons.phone_android, color: _getPhoneIconColor()),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    if (_phoneExists) {
                      return 'This phone number is already registered';
                    }
                    return null;
                  },
                ),
              ),
              if (_isCheckingPhone)
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (!_isPhoneVerified &&
                  _phoneController.text.length == 10 &&
                  !_phoneExists)
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: _isSendingPhoneOtp
                      ? CircularProgressIndicator(strokeWidth: 2)
                      : TextButton(
                          onPressed: _sendPhoneOtp,
                          child: Text(
                            'Verify',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              if (_isPhoneVerified)
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.verified, color: Colors.green, size: 20),
                ),
            ],
          ),
        ),
        if (_phoneExists && _phoneController.text.length == 10)
          Padding(
            padding: EdgeInsets.only(top: 4, left: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'This phone number is already linked to another account',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Simplified aadhaar verification field
  Widget _buildAadhaarVerificationField() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border:
                _aadhaarExists ? Border.all(color: Colors.red, width: 1) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _aadhaarController,
                  keyboardType: TextInputType.number,
                  enabled: !_isAadhaarVerified,
                  decoration: InputDecoration(
                    hintText: 'Aadhaar Card Number',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon:
                        Icon(Icons.credit_card, color: _getAadhaarIconColor()),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Aadhaar number';
                    }
                    if (value.length != 12) {
                      return 'Please enter a valid 12-digit Aadhaar number';
                    }
                    if (_aadhaarExists) {
                      return 'This Aadhaar number is already registered';
                    }
                    return null;
                  },
                ),
              ),
              if (_isCheckingAadhaar)
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (!_isAadhaarVerified &&
                  _aadhaarController.text.length == 12 &&
                  !_aadhaarExists)
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: _isSendingAadhaarOtp
                      ? CircularProgressIndicator(strokeWidth: 2)
                      : TextButton(
                          onPressed: _sendAadhaarOtp,
                          child: Text(
                            'Verify',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              if (_isAadhaarVerified)
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.verified, color: Colors.green, size: 20),
                ),
            ],
          ),
        ),
        if (_aadhaarExists && _aadhaarController.text.length == 12)
          Padding(
            padding: EdgeInsets.only(top: 4, left: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'This Aadhaar number is already linked to another account',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Phone OTP field
  Widget _buildPhoneOtpField() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneOtpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter OTP sent to your phone',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon:
                        Icon(Icons.sms_outlined, color: Colors.green.shade700),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: _isVerifyingPhoneOtp
                    ? CircularProgressIndicator(strokeWidth: 2)
                    : TextButton(
                        onPressed: _verifyPhoneOtp,
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Enter the 6-digit OTP sent to your phone',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Aadhaar OTP field
  Widget _buildAadhaarOtpField() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _aadhaarOtpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Aadhaar OTP',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon:
                        Icon(Icons.sms_outlined, color: Colors.green.shade700),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: _isVerifyingAadhaarOtp
                    ? CircularProgressIndicator(strokeWidth: 2)
                    : TextButton(
                        onPressed: _verifyAadhaarOtp,
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Enter the OTP sent to your Aadhaar registered mobile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.green.shade700),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey.shade600,
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}
