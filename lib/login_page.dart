import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'faculty_dashboard.dart';
import 'forgot_password_screen.dart'; // Add your forgot password screen import
import 'package:flutter/services.dart';
import 'database/faculty_db.dart';
import 'services/session_service.dart';
import 'dart:math' show sin, pi;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum UserRole { faculty, admin }

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  UserRole selectedRole = UserRole.faculty;
  final FacultyDatabase _facultyDB = FacultyDatabase();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

    _buttonAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  Future<bool> _validateFacultyCredentials(
      String username, String password) async {
    try {
      // Get faculty by username
      final faculty = await _facultyDB.getFacultyByUsername(username);

      if (faculty != null) {
        // Check if password matches
        return faculty.password == password;
      }
      return false;
    } catch (e) {
      print('Error validating faculty credentials: $e');
      return false;
    }
  }

  void _handleLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _controller.repeat(); // Start repeating animation during loading

    final username = _usernameController.text;
    final password = _passwordController.text;

    if (selectedRole == UserRole.admin) {
      if (username == 'admin123' && password == '123456789') {
        await SessionService.saveLoginSession('admin', username);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AdminDashboard(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      } else {
        _showErrorMessage('Invalid admin credentials');
      }
    } else {
      // Faculty login with similar animation
      final faculty = await _facultyDB.getFacultyByUsername(username);
      if (faculty != null && faculty.password == password) {
        await SessionService.saveLoginSession('faculty', username);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FacultyDashboard(
                facultyName: faculty.name,
                department: faculty.department,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      } else {
        _showErrorMessage('Invalid faculty credentials');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _controller.stop();
      _controller.forward(from: 0);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Color get _backgroundColor {
    return selectedRole == UserRole.admin
        ? const Color.fromRGBO(24, 29, 32, 1) // Dark base color
        : const Color.fromRGBO(28, 34, 38, 1); // Slightly lighter variant
  }

  Color get _containerColor {
    return selectedRole == UserRole.admin
        ? const Color.fromRGBO(32, 38, 42, 1) // Lighter container for admin
        : const Color.fromRGBO(36, 43, 48, 1); // Lighter container for faculty
  }

  Color get _inputFieldColor {
    return selectedRole == UserRole.admin
        ? const Color.fromRGBO(20, 24, 27, 1) // Darker input field for admin
        : const Color.fromRGBO(22, 27, 30, 1); // Darker input field for faculty
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color.fromRGBO(153, 55, 30, 1); // Warm red accent
    final textColor = const Color.fromRGBO(153, 55, 30, 1); // Light gray text

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: _containerColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: accentColor,
                        ),
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(0, 0, 0, 0),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: SegmentedButton<UserRole>(
                            segments: const [
                              ButtonSegment<UserRole>(
                                value: UserRole.faculty,
                                label: Text('Faculty'),
                                icon: Icon(Icons.school),
                              ),
                              ButtonSegment<UserRole>(
                                value: UserRole.admin,
                                label: Text('Admin'),
                                icon: Icon(Icons.admin_panel_settings),
                              ),
                            ],
                            selected: {selectedRole},
                            onSelectionChanged: (Set<UserRole> newSelection) {
                              setState(() {
                                selectedRole = newSelection.first;
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return accentColor;
                                  }
                                  return Colors.transparent;
                                },
                              ),
                              foregroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.white;
                                  }
                                  return textColor.withOpacity(0.7);
                                },
                              ),
                              iconColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.white;
                                  }
                                  return textColor.withOpacity(0.7);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _usernameController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle:
                                TextStyle(color: textColor.withOpacity(0.5)),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: accentColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: _inputFieldColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: textColor),
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle:
                                TextStyle(color: textColor.withOpacity(0.5)),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: accentColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: accentColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: _inputFieldColor,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.grey[300],
                            padding: EdgeInsets
                                .zero, // Remove padding to accommodate animation
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation:
                                _isLoading ? 4 : 8, // Add dynamic elevation
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _isLoading
                                ? 150
                                : null, // Fixed width when loading
                            child: _isLoading
                                ? _buildLoadingButton()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 50,
                                      vertical: 15,
                                    ),
                                    child: Text(
                                      'LOGIN AS ${selectedRole.name.toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 50,
        vertical: 15,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                          sin((_controller.value * 2 * pi) + (index * pi / 2))
                              .abs()),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
          // Animated border
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(120, 40),
                painter: LoadingBorderPainter(
                  animation: _controller.value,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class LoadingBorderPainter extends CustomPainter {
  final double animation;
  final Color color;

  LoadingBorderPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final width = size.width;
    final height = size.height;

    for (var i = 0; i < width; i++) {
      final x = i.toDouble();
      final y = sin((x / width * 4 * pi) + (animation * 2 * pi)) * 4;
      if (i == 0) {
        path.moveTo(x, height / 2 + y);
      } else {
        path.lineTo(x, height / 2 + y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LoadingBorderPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
