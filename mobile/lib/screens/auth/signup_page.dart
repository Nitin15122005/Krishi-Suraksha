import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import '../dashboard/dashboard_page.dart';
import 'package:agri_claim_mobile/services/api_service.dart'; 
import 'package:agri_claim_mobile/services/storage_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController(); 
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // This one boolean controls the entire UI state
  bool _showOtpField = false;
  
  // Loading state
  bool _isLoading = false;
  bool _isPasswordVisible = false; 
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _aadhaarController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // --- Step 1: Request the OTP ---
  Future<void> _handleRequestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final message = await _apiService.requestOtp(
        _mobileController.text,
        _aadhaarController.text,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      
      // Show the OTP field
      setState(() {
        _isLoading = false;
        _showOtpField = true;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  // --- Step 2: Verify OTP and Register ---
  Future<void> _handleVerifyAndRegister() async {
    // Add validation for password fields *only* if OTP field is shown
    if (_showOtpField && !_formKey.currentState!.validate()) return;
    
    // Check if passwords match
    if (_showOtpField && _passwordController.text != _confirmPasswordController.text) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
         );
         return;
    }
    
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.verifyOtpAndRegister(
        _mobileController.text,
        _aadhaarController.text,
        _otpController.text,
        _passwordController.text,
      );

      // --- REGISTRATION SUCCESSFUL ---
      await _storageService.saveSession(response);
      setState(() => _isLoading = false);
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (route) => false,
      );

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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
                          // ... (your shadows)
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _showOtpField 
                          ? 'Verify Your Identity'
                          : 'Create your farmer account',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                           // ... (your shadows)
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
                        // ... (your borders and shadows)
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            
                            // This AnimatedSwitcher handles the UI change
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _showOtpField
                                  ? _buildOtpForm() // State 2: Verify OTP
                                  : _buildDetailsForm(), // State 1: Enter Details
                            ),

                            SizedBox(height: 24),

                            // Main Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: _isLoading
                                ? ElevatedButton(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700.withOpacity(0.6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : ElevatedButton(
                                    onPressed: _showOtpField 
                                      ? _handleVerifyAndRegister
                                      : _handleRequestOtp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      _showOtpField ? 'Verify & Register' : 'Send OTP',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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
                                  style: GoogleFonts.inter(color: Colors.white),
                                ),
                                GestureDetector(
                                  onTap: _navigateToLogin,
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.inter(
                                      color: Colors.green.shade300,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
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

  // State 1: The form for entering Mobile and Aadhar
  Widget _buildDetailsForm() {
    return Column(
      key: ValueKey('details'),
      children: [
        _buildFormField(
          controller: _mobileController,
          hintText: 'Mobile Number (10 digits)',
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.length != 10) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildFormField(
          controller: _aadhaarController,
          hintText: 'Aadhaar Number (12 digits)',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.length != 12) {
              return 'Please enter a valid 12-digit Aadhaar number';
            }
            return null;
          },
        ),
      ],
    );
  }

  // State 2: The form for entering the OTP
  Widget _buildOtpForm() {
    return Column(
      key: ValueKey('otp'),
      children: [
        Text(
          'An OTP has been sent to your registered mobile (check your Go terminal).',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        ),
        SizedBox(height: 20),
        _buildFormField(
          controller: _otpController,
          hintText: 'Enter 6-Digit OTP',
          icon: Icons.sms_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.length != 6) {
              return 'Please enter the 6-digit OTP';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        // Password Fields
        _buildPasswordField( // New Password
          controller: _passwordController,
          hintText: 'Create Password (min 6 chars)',
          isPasswordVisible: _isPasswordVisible,
          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
          },
        ),
        SizedBox(height: 16),
        _buildPasswordField( // Confirm Password
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          isPasswordVisible: _isConfirmPasswordVisible,
          onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
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
      ],
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

  // Re-usable form field widget
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
}