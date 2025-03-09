import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../login_page.dart';
import 'change_credentials_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:isolate';
import '../services/faculty_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FacultySettingsPage extends StatefulWidget {
  final String facultyName;
  final String department;
  final String designation;
  final String experience;
  final String qualifications;
  final List<String> subjects;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final Function(String)? onChanged;
  final DateTime dateOfBirth;

  const FacultySettingsPage({
    super.key,
    required this.facultyName,
    required this.department,
    required this.designation,
    required this.experience,
    required this.qualifications,
    required this.subjects,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.onChanged,
    required this.dateOfBirth,
  });

  @override
  State<FacultySettingsPage> createState() => _FacultySettingsPageState();
}

class _FacultySettingsPageState extends State<FacultySettingsPage>
    with SingleTickerProviderStateMixin {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _designationController;
  late TextEditingController _experienceController;
  late TextEditingController _qualificationsController;
  late TextEditingController _subjectsController;
  final List<TextEditingController> _subjectControllers = [];
  final List<Map<String, TextEditingController>> _qualificationControllers = [];
  final GlobalKey<AnimatedListState> _qualificationsListKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _subjectsListKey =
      GlobalKey<AnimatedListState>();
  final StreamController<Map<String, dynamic>> _updateController =
      StreamController<Map<String, dynamic>>.broadcast();
  late AnimationController _controller;

  // Define colors
  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  // Add this at the top of the class
  final List<String> _designations = [
    'Dean',
    'Head of Department',
    'Professor',
    'Associate Professor',
    'Assistant Professor',
    'Guest Faculty',
    'Visiting Faculty',
    'Research Associate',
    'Lab Assistant',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.facultyName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _designationController = TextEditingController(
        text: widget.designation.isEmpty
            ? _designations.first
            : widget.designation);
    _experienceController = TextEditingController(text: widget.experience);
    _qualificationsController =
        TextEditingController(text: widget.qualifications);
    _subjectsController =
        TextEditingController(text: widget.subjects.join(', '));

    // Initialize subject controllers
    if (widget.subjects.isEmpty) {
      _addNewSubjectField();
    } else {
      for (var subject in widget.subjects) {
        _subjectControllers.add(TextEditingController(text: subject));
      }
    }

    // Load qualifications from Firestore
    FirebaseFirestore.instance
        .collection('faculty')
        .where('name', isEqualTo: widget.facultyName)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final qualList = data['qualificationsList'] as List?;

        if (qualList != null && qualList.isNotEmpty) {
          setState(() {
            _qualificationControllers.clear();
            for (var qual in qualList) {
              _qualificationControllers.add({
                'degree': TextEditingController(text: qual['degree'] ?? ''),
                'year': TextEditingController(text: qual['year'] ?? ''),
              });
            }
          });
        } else {
          _addNewQualificationField();
        }
      }
    });

    // TODO: Load profile image from Firebase Storage
    // if (widget.profileImageUrl != null) {
    //   _profileImage = File(...); // Load from cache or download
    // }

    // Setup real-time listener
    _setupRealtimeListener();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.forward();
  }

  void _setupRealtimeListener() {
    FirebaseFirestore.instance
        .collection('faculty')
        .where('name', isEqualTo: widget.facultyName)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty && mounted) {
        final data = snapshot.docs.first.data();
        _updateController.add(data);

        setState(() {
          // Update controllers with new data
          _qualificationsController.text = data['qualifications'] ?? '';
          _subjectsController.text =
              (data['subjects'] as List<dynamic>?)?.join(', ') ?? '';

          // Update qualification fields
          _updateQualificationFields(data['qualifications'] ?? '');

          // Update subject fields
          _updateSubjectFields(List<String>.from(data['subjects'] ?? []));
        });

        // Show update animation
        _showUpdateAnimation();
      }
    });
  }

  void _showUpdateAnimation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SizedBox(
          height: 50,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.sync, color: accentColor),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Profile Updated',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Changes applied successfully',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: cardColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _updateQualificationFields(String qualifications) {
    final qualList =
        qualifications.split(';').where((q) => q.trim().isNotEmpty).map((q) {
      final parts = q.split('(');
      final degree = parts[0].trim();
      final year = parts.length > 1 ? parts[1].replaceAll(')', '').trim() : '';
      return {'degree': degree, 'year': year};
    }).toList();

    // Animate out old fields and in new fields
    _qualificationControllers.clear();
    for (var qual in qualList) {
      final newControllers = {
        'degree': TextEditingController(text: qual['degree']),
        'year': TextEditingController(text: qual['year']),
      };
      _qualificationControllers.add(newControllers);
      _qualificationsListKey.currentState
          ?.insertItem(_qualificationControllers.length - 1);
    }
  }

  void _updateSubjectFields(List<String> subjects) {
    // Animate out old fields and in new fields
    _subjectControllers.clear();
    for (var subject in subjects) {
      final controller = TextEditingController(text: subject);
      _subjectControllers.add(controller);
      _subjectsListKey.currentState?.insertItem(_subjectControllers.length - 1);
    }
  }

  void _addNewSubjectField() {
    setState(() {
      _subjectControllers.add(TextEditingController());
      if (_subjectsListKey.currentState != null) {
        _subjectsListKey.currentState!
            .insertItem(_subjectControllers.length - 1);
      }
    });
  }

  void _removeSubjectField(int index) {
    final controller = _subjectControllers[index];
    setState(() {
      _subjectControllers.removeAt(index);
      controller.dispose();
      if (_subjectsListKey.currentState != null) {
        _subjectsListKey.currentState!.removeItem(
          index,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: Container(), // Empty container for smooth animation
          ),
        );
      }
    });
  }

  void _addNewQualificationField() {
    final newControllers = {
      'degree': TextEditingController(),
      'year': TextEditingController(),
    };

    setState(() {
      _qualificationControllers.add(newControllers);
      _qualificationsListKey.currentState
          ?.insertItem(_qualificationControllers.length - 1);
    });
  }

  void _removeQualificationField(int index) {
    final removedItem = _qualificationControllers[index];
    final removedWidget = _buildQualificationItem(
        removedItem, index, const AlwaysStoppedAnimation(1));

    setState(() {
      _qualificationControllers.removeAt(index);
    });

    _qualificationsListKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: removedWidget,
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    // Dispose controllers after animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      removedItem['degree']?.dispose();
      removedItem['year']?.dispose();
    });
  }

  Widget _buildQualificationItem(Map<String, TextEditingController> controllers,
      int index, Animation<double> animation) {
    final size = MediaQuery.of(context).size;

    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1, 0), end: Offset.zero).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // Header with index
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.01,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: accentColor,
                      size: size.width * 0.045,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'Qualification ${index + 1}',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red.withOpacity(0.7),
                        size: size.width * 0.045,
                      ),
                      onPressed: () => _removeQualificationField(index),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Input fields
              Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Column(
                  children: [
                    // Degree field
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor.withOpacity(0.2)),
                      ),
                      child: TextField(
                        controller: controllers['degree'],
                        style: TextStyle(
                          color: textColor,
                          fontSize: size.width * 0.035,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Degree',
                          hintStyle: TextStyle(
                            color: textColor.withOpacity(0.5),
                            fontSize: size.width * 0.035,
                          ),
                          prefixIcon: Icon(
                            Icons.school_outlined,
                            color: accentColor,
                            size: size.width * 0.045,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.height * 0.01,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Year field
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor.withOpacity(0.2)),
                      ),
                      child: TextField(
                        controller: controllers['year'],
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: textColor,
                          fontSize: size.width * 0.035,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Year',
                          hintStyle: TextStyle(
                            color: textColor.withOpacity(0.5),
                            fontSize: size.width * 0.035,
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_today_outlined,
                            color: accentColor,
                            size: size.width * 0.045,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.height * 0.01,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _experienceController.dispose();
    _qualificationsController.dispose();
    _subjectsController.dispose();
    for (var controller in _subjectControllers) {
      controller.dispose();
    }
    for (var controllers in _qualificationControllers) {
      controllers['degree']?.dispose();
      controllers['year']?.dispose();
    }
    _updateController.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });

        // TODO: Upload image to Firebase Storage
        // Example:
        // final storageRef = FirebaseStorage.instance.ref();
        // final imageRef = storageRef.child('faculty_profiles/${widget.facultyName}');
        // await imageRef.putFile(_profileImage!);
        // final imageUrl = await imageRef.getDownloadURL();
        // Update profileImageUrl in Firestore
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Text('Settings', style: TextStyle(color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Card
              _buildProfileCard(),

              const SizedBox(height: 24),

              // Settings Options
              _buildSettingsCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: 'profile_image',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: accentColor.withOpacity(0.2),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Text(
                            widget.facultyName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.facultyName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.department,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 45, // Fixed height for better control
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.9),
                    Color.fromRGBO(173, 75, 50, 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _showEditProfileDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
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
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.security,
            title: 'Change Credentials',
            onTap: () => _showChangeCredentialsDialog(),
            isDestructive: false,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor.withOpacity(0.1), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          _buildSettingTile(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _showLogoutDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: height * 0.8, // Maximum 80% of screen height
            maxWidth: width * 0.9, // Maximum 90% of screen width
          ),
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
              // Header
              Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(width * 0.05),
                    topRight: Radius.circular(width * 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: width * 0.06),
                    SizedBox(width: width * 0.02),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Image
              Container(
                margin: EdgeInsets.only(top: height * 0.02),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: width * 0.12,
                        backgroundColor: accentColor.withOpacity(0.1),
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: textColor.withOpacity(0.8),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              // Form Fields
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    width * 0.04,
                    height * 0.02,
                    width * 0.04,
                    height * 0.01,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAnimatedDialogField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person_outline,
                      ),
                      _buildAnimatedDialogField(
                        controller: _designationController,
                        label: 'Designation',
                        icon: Icons.work,
                        isDropdown: true,
                        dropdownItems: _designations,
                      ),
                      _buildAnimatedDialogField(
                        controller: _experienceController,
                        label: 'Experience',
                        icon: Icons.access_time,
                      ),
                      _buildQualificationsField(),
                      const SizedBox(height: 16),
                      _buildSubjectsField(),
                      _buildAnimatedDialogField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildAnimatedDialogField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(width * 0.05),
                    bottomRight: Radius.circular(width * 0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: width * 0.05),
                      label: Text(
                        'Cancel',
                        style: TextStyle(fontSize: width * 0.035),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: textColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03,
                          vertical: height * 0.01,
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 40, // Smaller height for dialog button
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.9),
            Color.fromRGBO(173, 75, 50, 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    bool isDropdown = false,
    List<String>? dropdownItems,
  }) {
    final size = MediaQuery.of(context).size;

    // Make email and phone read-only
    bool isReadOnly = label == 'Email' || label == 'Phone';

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      decoration: BoxDecoration(
        color: isReadOnly ? backgroundColor.withOpacity(0.5) : backgroundColor,
        borderRadius: BorderRadius.circular(size.width * 0.03),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
        ),
      ),
      child: isDropdown
          ? DropdownButtonFormField<String>(
              value: controller.text.isEmpty
                  ? dropdownItems?.first
                  : controller.text,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: size.width * 0.035,
                ),
                prefixIcon: Icon(
                  icon,
                  color:
                      isReadOnly ? accentColor.withOpacity(0.5) : accentColor,
                  size: size.width * 0.05,
                ),
                suffixIcon: isReadOnly
                    ? Icon(Icons.lock_outline,
                        color: accentColor.withOpacity(0.5),
                        size: size.width * 0.04)
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.015,
                ),
              ),
              dropdownColor: cardColor,
              style: TextStyle(
                color: textColor,
                fontSize: size.width * 0.035,
              ),
              icon: Icon(Icons.arrow_drop_down, color: accentColor),
              items: dropdownItems?.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        _getDesignationIcon(value),
                        color: accentColor,
                        size: size.width * 0.045,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(value, style: TextStyle(color: textColor)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    controller.text = newValue;
                    widget.onChanged?.call(newValue);
                  });
                }
              },
            )
          : TextField(
              controller: controller,
              readOnly: isReadOnly, // Make field read-only
              style: TextStyle(
                color: isReadOnly ? textColor.withOpacity(0.7) : textColor,
                fontSize: size.width * 0.035,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: size.width * 0.035,
                ),
                prefixIcon: Icon(
                  icon,
                  color:
                      isReadOnly ? accentColor.withOpacity(0.5) : accentColor,
                  size: size.width * 0.05,
                ),
                suffixIcon: isReadOnly
                    ? Icon(Icons.lock_outline,
                        color: accentColor.withOpacity(0.5),
                        size: size.width * 0.04)
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.015,
                ),
              ),
              keyboardType: keyboardType,
              maxLines: maxLines ?? 1,
            ),
    );
  }

  IconData _getDesignationIcon(String designation) {
    final Map<String, IconData> designationIcons = {
      'Dean': Icons.school,
      'Head of Department': Icons.account_balance,
      'Professor': Icons.psychology,
      'Associate Professor': Icons.menu_book,
      'Assistant Professor': Icons.person_outline,
      'Guest Faculty': Icons.card_membership,
      'Visiting Faculty': Icons.directions_walk,
      'Research Associate': Icons.science,
      'Lab Assistant': Icons.computer,
    };
    return designationIcons[designation] ?? Icons.work;
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    BoxDecoration? decoration,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : textColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : textColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red : textColor,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Logout', style: TextStyle(color: textColor)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showChangeCredentialsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeCredentialsPage(
          email: widget.email,
          phone: widget.phone,
        ),
      ),
    );
  }

  Widget _buildQualificationsField() {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(size.width * 0.02),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.school,
                    color: accentColor,
                    size: size.width * 0.05,
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Text(
                  'Qualifications',
                  style: TextStyle(
                    color: textColor,
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          AnimatedList(
            key: _qualificationsListKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: _qualificationControllers.length,
            itemBuilder: (context, index, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: _buildQualificationItem(
                  _qualificationControllers[index],
                  index,
                  animation,
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: ElevatedButton.icon(
              onPressed: _addNewQualificationField,
              icon: Icon(Icons.add_circle_outline, size: size.width * 0.05),
              label: const Text('Add Qualification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor.withOpacity(0.2),
                foregroundColor: accentColor,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: accentColor.withOpacity(0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsField() {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book,
                    color: accentColor, size: size.width * 0.06),
                SizedBox(width: size.width * 0.03),
                Text(
                  'Teaching Subjects',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Subjects List
          AnimatedList(
            key: _subjectsListKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: _subjectControllers.length,
            itemBuilder: (context, index, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: _buildSubjectItem(
                  _subjectControllers[index],
                  index,
                  animation,
                ),
              );
            },
          ),
          // Add Subject Button
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: ElevatedButton.icon(
              onPressed: _addNewSubjectField,
              icon: Icon(Icons.add_circle_outline, size: size.width * 0.05),
              label: Text(
                'Add New Subject',
                style: TextStyle(fontSize: size.width * 0.035),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor.withOpacity(0.2),
                foregroundColor: accentColor,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: accentColor.withOpacity(0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(TextEditingController controller, int index,
      Animation<double> animation) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Subject Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.height * 0.01,
            ),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.subject,
                  color: accentColor,
                  size: size.width * 0.045,
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  'Subject ${index + 1}',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.035,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red.withOpacity(0.7),
                    size: size.width * 0.045,
                  ),
                  onPressed: () => _removeSubjectField(index),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
          // Subject Input
          Container(
            padding: EdgeInsets.all(size.width * 0.03),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(
                  color: textColor,
                  fontSize: size.width * 0.035,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Subject Name',
                  hintStyle: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: size.width * 0.035,
                  ),
                  prefixIcon: Icon(
                    Icons.book_outlined,
                    color: accentColor,
                    size: size.width * 0.045,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: size.height * 0.01,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatQualifications() {
    // Parse qualifications into a structured format
    List<Map<String, String>> qualList = _qualificationControllers
        .map((controllers) {
          final degree = controllers['degree']?.text.trim() ?? '';
          final year = controllers['year']?.text.trim() ?? '';
          return {
            'degree': degree,
            'year': year,
          };
        })
        .where((qual) => qual['degree']!.isNotEmpty)
        .toList();

    // Sort by year in ascending order
    qualList.sort((a, b) {
      int yearA = int.tryParse(a['year'] ?? '') ?? 0;
      int yearB = int.tryParse(b['year'] ?? '') ?? 0;
      return yearA.compareTo(yearB);
    });

    // Format qualifications in a clean way
    return qualList.map((qual) {
      final degree = qual['degree'];
      final year = qual['year'];
      if (year?.isEmpty ?? true) return degree;
      return '$degree ($year)';
    }).join('\n');
  }

  Widget _buildQualificationCard(Map<String, dynamic> qualification) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              qualification['degree'] ?? '',
              style: TextStyle(
                color: textColor,
                fontSize: size.width * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (qualification['year']?.isNotEmpty ?? false)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                qualification['year'] ?? '',
                style: TextStyle(
                  color: accentColor,
                  fontSize: size.width * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;

    // Show loading dialog with smooth animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 400),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.05),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(size.width * 0.04),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 1500),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, double value, child) {
                            return Transform.rotate(
                              angle: value * 2 * 3.14,
                              child: Container(
                                padding: EdgeInsets.all(size.width * 0.04),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      accentColor),
                                  strokeWidth: 3,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          'Saving Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          'Please wait while we update your profile...',
                          style: TextStyle(
                            color: textColor,
                            fontSize: size.width * 0.035,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    try {
      // Validate experience input
      final experience = _experienceController.text.trim();
      if (experience.isEmpty) {
        throw 'Experience cannot be empty';
      }

      // Filter out empty qualifications
      final qualifications = _qualificationControllers
          .map((controller) => {
                'degree': controller['degree']?.text.trim() ?? '',
                'year': controller['year']?.text.trim() ?? '',
              })
          .where((qual) => qual['degree']!.isNotEmpty)
          .toList();

      // Prepare data
      final Map<String, dynamic> data = {
        'name': _nameController.text.trim(),
        'designation': _designationController.text.trim(),
        'experience': experience,
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dateOfBirth': widget.dateOfBirth.toIso8601String(),
        'qualificationsList': qualifications,
        'subjects': _subjectControllers
            .map((controller) => controller.text.trim())
            .where((subject) => subject.isNotEmpty)
            .toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // Update Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('faculty')
          .where('name', isEqualTo: widget.facultyName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update(data);

        await Future.delayed(Duration(milliseconds: 800));

        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog

        // Show success dialog with smooth animation
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => TweenAnimationBuilder(
            duration: const Duration(milliseconds: 400),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.95 + (0.05 * value),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.05),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(size.width * 0.04),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: Container(
                                  padding: EdgeInsets.all(size.width * 0.04),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: size.width * 0.1,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: size.height * 0.02),
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _controller,
                              curve: Curves.easeOutCubic,
                            )),
                            child: FadeTransition(
                              opacity: _controller,
                              child: Column(
                                children: [
                                  Text(
                                    'Success!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    'Your profile has been updated',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: size.width * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );

        await Future.delayed(Duration(milliseconds: 800));
        if (!mounted) return;

        Navigator.pop(context, data);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      // Show error with smooth animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          animation: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    }
  }
}

// Add this class at the top of the file
class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key, String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            key: key,
            backgroundColor: Colors.black54,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      message,
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

// Add this function at the top level of the file
Map<String, dynamic> _prepareData(Map<String, dynamic> input) {
  // Format qualifications with better structure
  final qualifications = (input['qualifications'] as List).where((q) {
    final degree = q['degree']?.toString().trim() ?? '';
    return degree.isNotEmpty;
  }).map((q) {
    final degree = q['degree']?.toString().trim() ?? '';
    final year = q['year']?.toString().trim() ?? '';

    // Create a structured format for each qualification
    return {
      'degree': degree,
      'year': year,
      'formatted': year.isNotEmpty ? '$degree ($year)' : degree,
    };
  }).toList()
    ..sort((a, b) => (int.tryParse(a['year'] ?? '0') ?? 0)
        .compareTo(int.tryParse(b['year'] ?? '0') ?? 0));

  // Create the final data structure
  return {
    ...input,
    'qualifications': qualifications.map((q) => q['formatted']).join('; '),
    'qualificationsList': qualifications, // Store structured data
    'subjects': (input['subjects'] as List)
        .where((s) => s.toString().trim().isNotEmpty)
        .toList(),
    'lastUpdated': DateTime.now().toIso8601String(),
  };
}
