// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import '../dashboard/dashboard_page.dart';

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

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {});
    });
    _aadhaarController.addListener(() {
      setState(() {});
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

      // Prepare farmer data for database
      Map<String, dynamic> farmerData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'address': _addressController.text,
        'aadhaarNumber': _aadhaarController.text,
        'isPhoneVerified': _isPhoneVerified,
        'isAadhaarVerified': _isAadhaarVerified,
      };

      // BACKEND: Register farmer API integration
      await _registerFarmer(farmerData);
    }
  }

  Future<void> _registerFarmer(Map<String, dynamic> farmerData) async {
    try {
      // TODO: BACKEND - Replace with actual API call
      // Example API structure:
      /*
      final response = await http.post(
        Uri.parse('https://your-api.com/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(farmerData),
      );
      
      if (response.statusCode == 201) {
        final userData = json.decode(response.body);
        // Save token to shared preferences
        // Navigate to dashboard
        _navigateToDashboard();
      } else {
        // Handle error
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
      */

      // Simulate API delay
      await Future.delayed(Duration(seconds: 2));

      // BACKEND: Remove this simulation after API integration
      // For now, simulate successful registration
      _navigateToDashboard();
    } catch (e) {
      // BACKEND: Handle API errors
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

    setState(() {
      _isSendingPhoneOtp = true;
    });

    // BACKEND: Send OTP API integration
    try {
      // TODO: Replace with actual OTP API call
      /*
      final response = await http.post(
        Uri.parse('https://your-api.com/auth/send-otp'),
        body: {
          'phone': _phoneController.text,
          'type': 'phone_verification',
        },
      );
      */

      await Future.delayed(Duration(seconds: 2));

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

    // BACKEND: Verify OTP API integration
    try {
      // TODO: Replace with actual OTP verification API call
      /*
      final response = await http.post(
        Uri.parse('https://your-api.com/auth/verify-otp'),
        body: {
          'phone': _phoneController.text,
          'otp': _phoneOtpController.text,
          'type': 'phone_verification',
        },
      );
      */

      await Future.delayed(Duration(seconds: 2));

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

    setState(() {
      _isSendingAadhaarOtp = true;
    });

    // BACKEND: Send Aadhaar OTP API integration
    try {
      // TODO: Replace with actual Aadhaar OTP API call
      await Future.delayed(Duration(seconds: 2));

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

    // BACKEND: Verify Aadhaar OTP API integration
    try {
      // TODO: Replace with actual Aadhaar OTP verification API call
      await Future.delayed(Duration(seconds: 2));

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

                            // Phone Number with Verification
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
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
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.phone_android,
                                          color: _isPhoneVerified
                                              ? Colors.green
                                              : Colors.green.shade700,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your mobile number';
                                        }
                                        if (value.length != 10) {
                                          return 'Please enter a valid 10-digit mobile number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  // Show Verify button automatically when 10 digits are entered
                                  if (!_isPhoneVerified &&
                                      _phoneController.text.length == 10)
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: _isSendingPhoneOtp
                                          ? CircularProgressIndicator(
                                              strokeWidth: 2,
                                            )
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
                                      child: Icon(
                                        Icons.verified,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),

                            // Phone OTP Field
                            if (_showPhoneOtpField && !_isPhoneVerified)
                              Column(
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
                                              hintText:
                                                  'Enter OTP sent to your phone',
                                              hintStyle: TextStyle(
                                                color: Colors.grey.shade400,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.sms_outlined,
                                                color: Colors.green.shade700,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: _isVerifyingPhoneOtp
                                              ? CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                )
                                              : TextButton(
                                                  onPressed: _verifyPhoneOtp,
                                                  child: Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.green.shade700,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                  SizedBox(height: 8),
                                ],
                              ),
                            SizedBox(height: 16),

                            // Aadhaar Number with Verification
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
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
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.credit_card,
                                          color: _isAadhaarVerified
                                              ? Colors.green
                                              : Colors.green.shade700,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your Aadhaar number';
                                        }
                                        if (value.length != 12) {
                                          return 'Please enter a valid 12-digit Aadhaar number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  // Show Verify button automatically when 12 digits are entered
                                  if (!_isAadhaarVerified &&
                                      _aadhaarController.text.length == 12)
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: _isSendingAadhaarOtp
                                          ? CircularProgressIndicator(
                                              strokeWidth: 2,
                                            )
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
                                      child: Icon(
                                        Icons.verified,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),

                            // Aadhaar OTP Field
                            if (_showAadhaarOtpField && !_isAadhaarVerified)
                              Column(
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
                                              hintStyle: TextStyle(
                                                color: Colors.grey.shade400,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.sms_outlined,
                                                color: Colors.green.shade700,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: _isVerifyingAadhaarOtp
                                              ? CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                )
                                              : TextButton(
                                                  onPressed: _verifyAadhaarOtp,
                                                  child: Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.green.shade700,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                  SizedBox(height: 8),
                                ],
                              ),
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
