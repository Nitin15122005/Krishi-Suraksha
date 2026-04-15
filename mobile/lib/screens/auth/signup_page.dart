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

  bool _showOtpField = false;
  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<void> _handleRequestOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final message = await _apiService.requestOtp(
        _mobileController.text,
        _aadhaarController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );

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

  Future<void> _handleVerifyAndRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
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

      await _storageService.saveSession(response);

      setState(() => _isLoading = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
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
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/Signup.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                   padding: const EdgeInsets.symmetric(
  horizontal: 32,
  vertical: 48,
),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(200, 100),
                        bottomRight: Radius.elliptical(200, 100),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Create Account",
                              style: GoogleFonts.ptSerif(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(23, 51, 0, 1),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _showOtpField
                                  ? "Verify your account"
                                  : "Start smart farming journey",
                              style: GoogleFonts.ptSerif(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 25),

                            _buildInputField(
                              controller: _mobileController,
                              hint: "Mobile Number",
                              icon: Icons.phone_android,
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _aadhaarController,
                              hint: "Aadhaar Number",
                              icon: Icons.credit_card,
                            ),

                            const SizedBox(height: 16),

                            if (_showOtpField) ...[
                              _buildInputField(
                                controller: _otpController,
                                hint: "Enter OTP",
                                icon: Icons.sms_outlined,
                              ),
                              const SizedBox(height: 16),

                              _buildInputField(
                                controller: _passwordController,
                                hint: "Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 16),

                              _buildInputField(
                                controller: _confirmPasswordController,
                                hint: "Confirm Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                            ],

                            const SizedBox(height: 25),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : (_showOtpField
                                        ? _handleVerifyAndRegister
                                        : _handleRequestOtp),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA9E981),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _showOtpField ? "Register" : "Send OTP",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    "or",
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 20),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),

                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: _navigateToLogin,
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green.shade800,
                                  fontSize: 15,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.green.shade700, width: 1.5),
        ),
      ),
    );
  }
}