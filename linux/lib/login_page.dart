import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'faculty_dashboard.dart';
import 'forgot_password_screen.dart'; // Add your forgot password screen import

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

  void _handleLogin() {
    if (selectedRole == UserRole.admin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const FacultyDashboard(
            facultyName: 'John Doe',
            department: 'Computer Science',
          ),
        ),
      );
    }
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
    final textColor = const Color.fromRGBO(159, 160, 162, 1); // Light gray text

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
                              iconColor:
                                  WidgetStateProperty.resolveWith<Color>(
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
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle:
                                TextStyle(color: textColor.withOpacity(0.5)),
                            prefixIcon: Icon(
                              Icons.lock_outline,
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
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: textColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'LOGIN AS ${selectedRole.name.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                              color: textColor.withOpacity(0.7),
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

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
