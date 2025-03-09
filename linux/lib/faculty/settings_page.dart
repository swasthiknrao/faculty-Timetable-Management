import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../login_page.dart';
import 'change_credentials_page.dart';

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
  });

  @override
  State<FacultySettingsPage> createState() => _FacultySettingsPageState();
}

class _FacultySettingsPageState extends State<FacultySettingsPage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _designationController;
  late TextEditingController _experienceController;
  late TextEditingController _qualificationsController;
  late TextEditingController _subjectsController;

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

    // TODO: Load profile image from Firebase Storage
    // if (widget.profileImageUrl != null) {
    //   _profileImage = File(...); // Load from cache or download
    // }
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          _buildProfileCard(),

          const SizedBox(height: 24),

          // Settings Options
          _buildSettingsCard(),
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
                            widget.facultyName[0],
                            style: const TextStyle(
                              fontSize: 40,
                              color: textColor,
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
            ElevatedButton.icon(
              onPressed: () => _showEditProfileDialog(),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardColor, width: 2),
                          ),
                          child: const Icon(Icons.edit,
                              size: 18, color: Colors.white),
                        ),
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
                      _buildAnimatedDialogField(
                        controller: _qualificationsController,
                        label: 'Qualifications',
                        icon: Icons.school,
                        maxLines: 3,
                      ),
                      _buildAnimatedDialogField(
                        controller: _subjectsController,
                        label: 'Subjects',
                        icon: Icons.menu_book,
                        maxLines: 2,
                      ),
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
                    ElevatedButton.icon(
                      onPressed: () {
                        final updatedData = {
                          'name': _nameController.text,
                          'designation': _designationController.text,
                          'experience': _experienceController.text,
                          'qualifications': _qualificationsController.text,
                          'subjects': _subjectsController.text,
                          'email': _emailController.text,
                          'phone': _phoneController.text,
                          'profileImageUrl': null,
                        };

                        // Return data and close dialog
                        Navigator.pop(context);
                        // Return data to dashboard
                        Navigator.pop(context, updatedData);

                        // Show success message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.save, size: width * 0.05),
                      label: Text(
                        'Save Changes',
                        style: TextStyle(fontSize: width * 0.035),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.02),
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
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      decoration: BoxDecoration(
        color: backgroundColor,
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
                  color: accentColor,
                  size: size.width * 0.05,
                ),
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
              style: TextStyle(
                color: textColor,
                fontSize: size.width * 0.035,
              ),
              keyboardType: keyboardType,
              maxLines: maxLines ?? 1,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: size.width * 0.035,
                ),
                prefixIcon: Icon(
                  icon,
                  color: accentColor,
                  size: size.width * 0.05,
                ),
                alignLabelWithHint: maxLines != null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.015,
                ),
              ),
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
}
