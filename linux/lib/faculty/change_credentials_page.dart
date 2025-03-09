import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class ChangeCredentialsPage extends StatefulWidget {
  final String email;
  final String phone;

  const ChangeCredentialsPage({
    super.key,
    required this.email,
    required this.phone,
  });

  @override
  State<ChangeCredentialsPage> createState() => _ChangeCredentialsPageState();
}

class _ChangeCredentialsPageState extends State<ChangeCredentialsPage>
    with SingleTickerProviderStateMixin {
  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _timer;
  int _timeLeft = 120; // 2 minutes in seconds

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
   
      body: Stack(
        children: [
          // Animated background patterns
          ...List.generate(5, (index) {
            return AnimatedPositioned(
              duration: Duration(seconds: 3),
              curve: Curves.easeInOut,
              top: height * 0.1 * index + (index % 2 == 0 ? 20 : -20),
              right: -width * 0.2,
              child: Transform.rotate(
                angle: math.pi / 6,
                child: Container(
                  width: width * 0.7,
                  height: height * 0.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.2),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(width * 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Icon
                  Center(
                    child: TweenAnimationBuilder(
                      duration: Duration(seconds: 2),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: EdgeInsets.all(width * 0.05),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.security,
                              color: accentColor,
                              size: width * 0.15,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.04),

                  // Verification methods
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Verification Method',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.055,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Choose how you want to verify your identity',
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: width * 0.035,
                            ),
                          ),
                          SizedBox(height: height * 0.03),

                          // Enhanced verification cards
                          _buildAnimatedVerificationCard(
                            width: width,
                            height: height,
                            icon: Icons.phone_android,
                            title: 'Via SMS',
                            subtitle: widget.phone,
                            onTap: () => _sendOTP('phone', widget.phone),
                          ),
                          _buildAnimatedVerificationCard(
                            width: width,
                            height: height,
                            icon: Icons.mail_outlined,
                            title: 'Via Email',
                            subtitle: widget.email,
                            onTap: () => _sendOTP('email', widget.email),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Enhanced security note
                  SizedBox(height: height * 0.05),
                  TweenAnimationBuilder(
                    duration: Duration(seconds: 1),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: EdgeInsets.all(width * 0.04),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(width * 0.03),
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(width * 0.03),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.security,
                                  color: accentColor,
                                  size: width * 0.06,
                                ),
                              ),
                              SizedBox(width: width * 0.03),
                              Expanded(
                                child: Text(
                                  'For your security, we\'ll send a verification code to confirm it\'s you',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: width * 0.035,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedVerificationCard({
    required double width,
    required double height,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: height * 0.02),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(width * 0.04),
            child: Container(
              padding: EdgeInsets.all(width * 0.05),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(width * 0.04),
                border: Border.all(color: accentColor.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(width * 0.03),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: width * 0.07,
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.005),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: width * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: accentColor,
                    size: width * 0.05,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendOTP(String method, String destination) {
    // TODO: Implement actual OTP sending with Firebase
    _showOTPVerificationDialog();
  }

  void _showOTPVerificationDialog() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final otpControllers = List.generate(6, (index) => TextEditingController());
    final focusNodes = List.generate(6, (index) => FocusNode());

    // Generate a random 6-digit OTP
    final String generatedOTP =
        (100000 + math.Random().nextInt(900000)).toString();

    // TODO: Send this OTP via SMS/Email using Firebase
    print('Generated OTP: $generatedOTP'); // For testing

    _timeLeft = 120;
    _timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Use setDialogState to update dialog
          // Start timer if not already started
          _timer ??= Timer.periodic(Duration(seconds: 1), (timer) {
            setDialogState(() {
              // Use setDialogState instead of setState
              if (_timeLeft > 0) {
                _timeLeft--;
              } else {
                timer.cancel();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('OTP expired. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
          });

          String getTimeString() {
            int minutes = _timeLeft ~/ 60;
            int seconds = _timeLeft % 60;
            return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Container(
                width: width * 0.9,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(width * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: width * 0.05,
                      spreadRadius: width * 0.01,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline,
                        color: accentColor, size: width * 0.15),
                    SizedBox(height: height * 0.02),
                    Text(
                      'Enter Verification Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      'Enter the 6-digit code sent to your device',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: width * 0.035,
                      ),
                    ),
                    SizedBox(height: height * 0.03),

                    // OTP input fields with fixed sizing
                    SizedBox(
                      width: width * 0.7, // Reduce overall width
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // Space evenly
                        children: List.generate(
                          6,
                          (index) => SizedBox(
                            width: width * 0.1, // Fixed width for each box
                            height: width * 0.12, // Fixed height
                            child: Container(
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius:
                                    BorderRadius.circular(width * 0.02),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: otpControllers[index],
                                focusNode: focusNodes[index],
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.045, // Adjusted font size
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    // Add padding
                                    vertical: width * 0.02,
                                    horizontal: width * 0.01,
                                  ),
                                  isDense:
                                      true, // Make the input field more compact
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.02),
                                    borderSide: BorderSide(
                                        color: accentColor, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.02),
                                    borderSide: BorderSide(
                                      color: accentColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    focusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    Container(
                      margin: EdgeInsets.symmetric(vertical: height * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: accentColor,
                            size: width * 0.04,
                          ),
                          SizedBox(width: width * 0.01),
                          Text(
                            'Code expires in ${getTimeString()}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: width * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: textColor,
                              fontSize: width * 0.04,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            String enteredOTP = otpControllers
                                .map((controller) => controller.text)
                                .join();

                            if (enteredOTP == generatedOTP) {
                              _verifyOTP(enteredOTP);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Invalid OTP. Please try again.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.06,
                              vertical: height * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width * 0.02),
                            ),
                          ),
                          child: Text(
                            'Verify',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Add resend button
                    TextButton(
                      onPressed: _timeLeft == 0
                          ? () {
                              setDialogState(() {
                                _timeLeft = 120;
                                // TODO: Resend OTP via Firebase
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('New OTP sent!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              });
                            }
                          : null,
                      child: Text(
                        'Resend Code',
                        style: TextStyle(
                          color: _timeLeft == 0
                              ? accentColor
                              : textColor.withOpacity(0.5),
                          fontSize: width * 0.035,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).then((_) {
      // Cleanup
      _timer?.cancel();
      _timer = null;
      for (var controller in otpControllers) {
        controller.dispose();
      }
      for (var node in focusNodes) {
        node.dispose();
      }
    });
  }

  void _verifyOTP(String otp) {
    _timer?.cancel(); // Cancel timer when verifying
    Navigator.pop(context); // Close OTP dialog
    _showCredentialsForm(); // Show credentials form
  }

  void _showCredentialsForm() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(width * 0.05),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: width * 0.05,
                spreadRadius: width * 0.01,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Credentials',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.03),
              _buildTextField(
                controller: usernameController,
                label: 'New Username',
                width: width,
                height: height,
              ),
              SizedBox(height: height * 0.02),
              _buildTextField(
                controller: passwordController,
                label: 'New Password',
                isPassword: true,
                width: width,
                height: height,
              ),
              SizedBox(height: height * 0.02),
              _buildTextField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                isPassword: true,
                width: width,
                height: height,
              ),
              SizedBox(height: height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: textColor,
                        fontSize: width * 0.04,
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      if (passwordController.text ==
                          confirmPasswordController.text) {
                        // TODO: Update credentials in Firebase
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Credentials updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.06,
                        vertical: height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.02),
                      ),
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required double width,
    required double height,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: textColor.withOpacity(0.7),
          fontSize: width * 0.04,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.02),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.02),
          borderSide: BorderSide(color: accentColor),
        ),
      ),
    );
  }
}
