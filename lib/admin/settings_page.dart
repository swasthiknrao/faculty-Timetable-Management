import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../login_page.dart';
import '../utils/slide_route.dart';
import '../utils/otp_verification.dart';
import '../utils/dialog_route.dart';
import '../utils/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.accentColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Profile',
                children: [
                  _buildProfileHeader(),
                  _buildSettingsTile(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    subtitle: 'Update your information',
                    onTap: () => _showEditProfileDialog(context),
                  ),
                  _buildSettingsTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Appearance',
                children: [
                  _buildThemeToggle(),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Account',
                children: [
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () => _showLogoutDialog(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: themeProvider.accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: themeProvider.accentColor.withOpacity(0.2)),
                      image: _profileImage != null
                          ? DecorationImage(
                              image: FileImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImage == null
                        ? Icon(
                            Icons.person,
                            color: themeProvider.accentColor,
                            size: 40,
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: themeProvider.accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeProvider.backgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Name',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'admin@college.edu',
                    style: TextStyle(
                      color: themeProvider.textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SwitchListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeProvider.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 24,
              color: themeProvider.accentColor,
            ),
          ),
          title: Text(
            'Dark Mode',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Toggle dark/light theme',
            style: TextStyle(
              color: themeProvider.textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
          activeColor: themeProvider.accentColor,
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: 'Admin Name');
    final emailController = TextEditingController(text: 'admin@college.edu');
    final phoneController = TextEditingController(text: '9876543210');
    final dobController = TextEditingController(text: '01/01/1990');

    Navigator.of(context).push(PopupDialogRoute(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => AlertDialog(
          backgroundColor: themeProvider.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: themeProvider.accentColor.withOpacity(0.2)),
          ),
          title: Text(
            'Edit Profile',
            style: TextStyle(color: themeProvider.textColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: themeProvider.accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: themeProvider.accentColor.withOpacity(0.2),
                          ),
                          image: _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profileImage == null
                            ? Icon(
                                Icons.person,
                                color: themeProvider.accentColor,
                                size: 50,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeProvider.accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: themeProvider.backgroundColor,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: themeProvider.textColor),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon:
                        Icon(Icons.person, color: themeProvider.accentColor),
                    labelStyle: TextStyle(
                        color: themeProvider.textColor.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: themeProvider.accentColor.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: themeProvider.accentColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dobController,
                  style: TextStyle(color: themeProvider.textColor),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_today,
                        color: themeProvider.accentColor),
                    labelStyle: TextStyle(
                        color: themeProvider.textColor.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: themeProvider.accentColor.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: themeProvider.accentColor),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1990),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: themeProvider.accentColor,
                              surface: themeProvider.cardColor,
                              onSurface: themeProvider.textColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      dobController.text =
                          '${date.day}/${date.month}/${date.year}';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  style: TextStyle(color: themeProvider.textColor),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon:
                        Icon(Icons.phone, color: themeProvider.accentColor),
                    labelStyle: TextStyle(
                        color: themeProvider.textColor.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: themeProvider.accentColor.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: themeProvider.accentColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: themeProvider.textColor),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        Icon(Icons.email, color: themeProvider.accentColor),
                    labelStyle: TextStyle(
                        color: themeProvider.textColor.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: themeProvider.accentColor.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: themeProvider.accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: themeProvider.accentColor)),
            ),
            TextButton(
              onPressed: () {
                // Validate inputs
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    dobController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Implement profile update logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Save',
                  style: TextStyle(color: themeProvider.accentColor)),
            ),
          ],
        ),
      ),
    ));
  }

  void _showChangePasswordDialog(BuildContext context) {
    final emailController = TextEditingController(text: 'admin@college.edu');
    final phoneController = TextEditingController(text: '9876543210');
    bool useEmail = true;

    Navigator.of(context).push(PopupDialogRoute(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side:
                  BorderSide(color: themeProvider.accentColor.withOpacity(0.2)),
            ),
            title: Text(
              'Verify Identity',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeProvider.accentColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => useEmail = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: useEmail
                                  ? themeProvider.accentColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email,
                                  color: useEmail
                                      ? Colors.white
                                      : themeProvider.textColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    color: useEmail
                                        ? Colors.white
                                        : themeProvider.textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => useEmail = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !useEmail
                                  ? themeProvider.accentColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: !useEmail
                                      ? Colors.white
                                      : themeProvider.textColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Phone',
                                  style: TextStyle(
                                    color: !useEmail
                                        ? Colors.white
                                        : themeProvider.textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (useEmail)
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: themeProvider.textColor),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          Icon(Icons.email, color: themeProvider.accentColor),
                      labelStyle: TextStyle(
                          color: themeProvider.textColor.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: themeProvider.accentColor.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: themeProvider.accentColor),
                      ),
                    ),
                  ),
                if (!useEmail)
                  TextField(
                    controller: phoneController,
                    style: TextStyle(color: themeProvider.textColor),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon:
                          Icon(Icons.phone, color: themeProvider.accentColor),
                      labelStyle: TextStyle(
                          color: themeProvider.textColor.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: themeProvider.accentColor.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: themeProvider.accentColor),
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(color: themeProvider.accentColor)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final verified = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OTPVerification(
                        verificationMethod: useEmail ? 'email' : 'phone',
                        contact: useEmail
                            ? emailController.text
                            : phoneController.text,
                      ),
                    ),
                  );

                  if (verified == true) {
                    _showNewPasswordDialog(context);
                  }
                },
                child: Text('Send OTP',
                    style: TextStyle(color: themeProvider.accentColor)),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void _showNewPasswordDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Navigator.of(context).push(PopupDialogRoute(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => AlertDialog(
          backgroundColor: themeProvider.cardColor,
          title: Text(
            'Change Password',
            style: TextStyle(color: themeProvider.textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: TextStyle(color: themeProvider.textColor),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(
                      color: themeProvider.textColor.withOpacity(0.7)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: themeProvider.accentColor.withOpacity(0.2)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: themeProvider.accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: TextStyle(color: themeProvider.textColor),
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(
                      color: themeProvider.textColor.withOpacity(0.7)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: themeProvider.accentColor.withOpacity(0.2)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: themeProvider.accentColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: themeProvider.accentColor)),
            ),
            TextButton(
              onPressed: () {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  // Update password logic here
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Update',
                  style: TextStyle(color: themeProvider.accentColor)),
            ),
          ],
        ),
      ),
    ));
  }

  void _showLogoutDialog(BuildContext context) {
    Navigator.of(context).push(PopupDialogRoute(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => AlertDialog(
          backgroundColor: themeProvider.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: themeProvider.accentColor.withOpacity(0.2)),
          ),
          title: Text(
            'Logout',
            style: TextStyle(color: themeProvider.textColor),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: themeProvider.textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: themeProvider.accentColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  SlidePageRoute(
                    page: const LoginPage(),
                    direction: AxisDirection.right,
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: themeProvider.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side:
                  BorderSide(color: themeProvider.accentColor.withOpacity(0.2)),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: themeProvider.accentColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: themeProvider.textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: themeProvider.accentColor.withOpacity(0.7),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
