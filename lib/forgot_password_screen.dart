import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputController.dispose();
    super.dispose();
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Input is required';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final input = _inputController.text;

    setState(() => _isLoading = true);

    try {
      // Your logic to check if input is username, email, or phone number
      bool isUsername = input.contains(RegExp(r'^[a-zA-Z0-9_]+$'));
      bool isEmail = input.contains(RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'));
      bool isPhone = input.contains(RegExp(r'^\d{10}$'));

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (isUsername) {
        // Check if username exists in the database
        bool usernameExists = await _checkUsernameExists(input);
        if (usernameExists) {
          _sendOtpToPhone(input);
        } else {
          throw Exception('Username not found');
        }
      } else if (isEmail) {
        // Check if email exists in the database
        bool emailExists = await _checkEmailExists(input);
        if (emailExists) {
          _sendOtpToEmail(input);
        } else {
          throw Exception('Email not found');
        }
      } else if (isPhone) {
        // Check if phone number exists in the database
        bool phoneExists = await _checkPhoneExists(input);
        if (phoneExists) {
          _sendOtpToPhone(input);
        } else {
          throw Exception('Phone number not found');
        }
      } else {
        throw Exception('Invalid input');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _checkUsernameExists(String username) async {
    // Simulate checking username in the database
    await Future.delayed(const Duration(seconds: 1));
    return username == "existingUser";
  }

  Future<bool> _checkEmailExists(String email) async {
    // Simulate checking email in the database
    await Future.delayed(const Duration(seconds: 1));
    return email == "existing@example.com";
  }

  Future<bool> _checkPhoneExists(String phone) async {
    // Simulate checking phone number in the database
    await Future.delayed(const Duration(seconds: 1));
    return phone == "1234567890";
  }

  void _sendOtpToPhone(String phone) {
    // Simulate sending OTP to phone
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to your phone')),
    );
    // Navigate to OTP verification screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OtpVerificationScreen(),
      ),
    );
  }

  void _sendOtpToEmail(String email) {
    // Simulate sending OTP to email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to your email')),
    );
    // Navigate to OTP verification screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OtpVerificationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color.fromRGBO(24, 29, 32, 1);
    final cardColor = const Color.fromRGBO(34, 39, 42, 1);
    final accentColor = const Color.fromRGBO(153, 55, 30, 1);
    final textColor = const Color.fromRGBO(159, 160, 162, 1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Let\'s get you back on track!',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please enter your username, email, or phone number to receive an OTP.',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _inputController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Username, Email, or Phone',
                      labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: cardColor,
                      prefixIcon: Icon(Icons.person_outline, color: accentColor),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: accentColor.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: accentColor,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: _validateInput,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Reset Password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color.fromRGBO(24, 29, 32, 1);
    final cardColor = const Color.fromRGBO(34, 39, 42, 1);
    final accentColor = const Color.fromRGBO(153, 55, 30, 1);
    final textColor = const Color.fromRGBO(159, 160, 162, 1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: const Text('OTP Verification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the OTP sent to your phone/email',
                style: TextStyle(color: textColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'OTP',
                  labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: cardColor,
                  prefixIcon: Icon(Icons.lock_outline, color: accentColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: accentColor.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: accentColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Handle OTP verification
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
