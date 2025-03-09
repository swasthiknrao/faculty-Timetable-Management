import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faculty.dart';
import '../database/faculty_db.dart';

class AddFaculty extends StatefulWidget {
  const AddFaculty({super.key});

  @override
  State<AddFaculty> createState() => _AddFacultyState();
}

class _AddFacultyState extends State<AddFaculty> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _facultyDB = FacultyDatabase();

  // Add all controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _designationController = TextEditingController();
  final _experienceController = TextEditingController();

  // Add other required variables
  String? selectedDepartment;
  DateTime selectedDate = DateTime.now();
  List<String> selectedSubjects = [];
  List<Map<String, String>> qualifications = [];

  // Theme colors
  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _designationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  // Fix the validator to be synchronous
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a username';
        }
        return null;
      },
      onChanged: (value) async {
        // Check uniqueness on change instead
        if (value.isNotEmpty) {
          final isUnique = await _isUsernameUnique(value);
          if (!isUnique && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('This username is already taken'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  Future<bool> _isUsernameUnique(String username) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('faculty')
          .where('username',
              isEqualTo: username.toLowerCase().trim()) // Convert to lowercase
          .limit(1) // Limit to 1 result for efficiency
          .get();

      return result.docs.isEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  Future<void> _addFaculty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if username is unique
      final isUnique = await _isUsernameUnique(_usernameController.text);
      if (!isUnique) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: cardColor,
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 10),
                Text('Username Already Exists',
                    style: TextStyle(color: textColor)),
              ],
            ),
            content: Text(
              'Please choose a different username.',
              style: TextStyle(color: textColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: accentColor)),
              ),
            ],
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // If username is unique, proceed with adding faculty
      final faculty = Faculty(
        id: '',
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        department: selectedDepartment!,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        dateOfBirth: selectedDate,
        designation: _designationController.text,
        experience: _experienceController.text,
        subjects: selectedSubjects,
        qualifications: qualifications
            .map((q) => '${q['degree']} (${q['year']})')
            .join(', '),
      );

      await _facultyDB.addFaculty(faculty);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Faculty added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding faculty: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Text('Add Faculty', style: TextStyle(color: textColor)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildUsernameField(),
              // Add other form fields here
            ],
          ),
        ),
      ),
    );
  }
}
