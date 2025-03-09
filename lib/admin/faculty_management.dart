import 'package:flutter/material.dart';
import 'dart:async';
import '../models/faculty.dart';
import '../database/department_db.dart';
import '../database/faculty_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Action classes for tracking changes
class ActionHistory {
  final List<dynamic> _undoStack = [];
  final List<dynamic> _redoStack = [];

  void addAction(dynamic action) {
    _undoStack.add(action);
    _redoStack.clear();
  }

  dynamic undo() {
    if (_undoStack.isNotEmpty) {
      final action = _undoStack.removeLast();
      _redoStack.add(action);
      return action;
    }
    return null;
  }

  dynamic redo() {
    if (_redoStack.isNotEmpty) {
      final action = _redoStack.removeLast();
      _undoStack.add(action);
      return action;
    }
    return null;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}

class DepartmentRenameAction {
  final String oldName;
  final String newName;
  DepartmentRenameAction({required this.oldName, required this.newName});
}

class DepartmentDeleteAction {
  final String departmentName;
  DepartmentDeleteAction({required this.departmentName});
}

class FacultyAddAction {
  final Faculty faculty;
  final String department;
  FacultyAddAction({required this.faculty, required this.department});
}

class FacultyDeleteAction {
  final Faculty faculty;
  final String department;
  FacultyDeleteAction({required this.faculty, required this.department});
}

class FacultyEditAction {
  final Faculty oldFaculty;
  final Faculty newFaculty;
  FacultyEditAction({required this.oldFaculty, required this.newFaculty});
}

class FacultyManagement extends StatefulWidget {
  const FacultyManagement({super.key});

  @override
  State<FacultyManagement> createState() => _FacultyManagementState();
}

class _FacultyManagementState extends State<FacultyManagement> {
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  final FacultyDatabase _facultyDB = FacultyDatabase();
  final DepartmentDatabase _departmentDB = DepartmentDatabase();

  List<String> departments = [];
  Map<String, List<Faculty>> facultyData = {};
  String? selectedDepartment;
  bool hasUnsavedChanges = false;

  final Map<String, IconData> _designationIcons = {
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

  IconData getDesignationIcon(String designation) =>
      _designationIcons[designation] ?? Icons.person;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  bool _isValidUsername(String username) {
    return username.length >= 4 && !username.contains(' ');
  }

  bool _isValidPassword(String password) {
    return password.length >= 4;
  }

  // Update the uniqueness check methods to accept an optional ID to exclude
  Future<bool> _isUsernameUnique(String username, {String? excludeId}) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('faculty')
          .where('username', isEqualTo: username.toLowerCase().trim())
          .get();
      return result.docs.every((doc) => doc.id == excludeId);
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  Future<bool> _isEmailUnique(String email, {String? excludeId}) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('faculty')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .get();
      return result.docs.every((doc) => doc.id == excludeId);
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  Future<bool> _isMobileUnique(String mobile, {String? excludeId}) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('faculty')
          .where('phone', isEqualTo: mobile.trim())
          .get();
      return result.docs.every((doc) => doc.id == excludeId);
    } catch (e) {
      print('Error checking mobile: $e');
      return false;
    }
  }

  String? _getErrorText(String value, String fieldName) {
    if (value.isEmpty) {
      return '$fieldName is required';
    }
    switch (fieldName) {
      case 'Email':
        return !_isValidEmail(value) ? 'Enter a valid email address' : null;
      case 'Mobile Number':
        return !_isValidPhone(value)
            ? 'Enter a valid 10-digit mobile number'
            : null;
      case 'Username':
        return !_isValidUsername(value)
            ? 'Username must be at least 4 characters without spaces'
            : null;
      case 'Password':
        return !_isValidPassword(value)
            ? 'Password must be at least 4 characters'
            : null;
      default:
        return null;
    }
  }

  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Color.fromRGBO(255, 82, 82, 1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Validation Errors',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...errors.map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right,
                          color: Color.fromRGBO(255, 82, 82, 1),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 82, 82, 1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      // Listen to departments stream
      _departmentDB.getDepartments().listen((depts) {
        setState(() {
          departments = depts;
          // Initialize faculty data map
          for (var dept in depts) {
            if (!facultyData.containsKey(dept)) {
              facultyData[dept] = [];
            }
          }
        });
      });
    } catch (e) {
      print('Error loading departments: $e');
    }
  }

  // Add key for ListView
  final GlobalKey<AnimatedListState> listKey = GlobalKey();

  // Cache department items
  final Map<String, Widget> _departmentItemCache = {};

  // Optimize department item building
  Widget _buildDepartmentItem(String department, bool isSelected) {
    final cacheKey = '$department-$isSelected';
    if (_departmentItemCache.containsKey(cacheKey)) {
      return _departmentItemCache[cacheKey]!;
    }

    final size = MediaQuery.of(context).size;
    final item = Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedDepartment = department;
              facultyData[department] ??= [];
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: size.width * 0.3,
            height: size.height * 0.08,
            decoration: BoxDecoration(
              color: isSelected || selectedDepartments.contains(department)
                  ? accentColor
                  : const Color.fromRGBO(24, 29, 32, 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected || selectedDepartments.contains(department)
                    ? accentColor
                    : accentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.category,
                  color: Color.fromRGBO(159, 160, 162, 1),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  department,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        isSelected || selectedDepartments.contains(department)
                            ? Colors.white
                            : const Color.fromRGBO(159, 160, 162, 1),
                    fontSize: 14,
                    fontWeight:
                        isSelected || selectedDepartments.contains(department)
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _departmentItemCache[cacheKey] = item;
    return item;
  }

  bool _isSaving = false;
  bool isEditMode = false;
  List<String> selectedDepartments = [];

  final ActionHistory _actionHistory = ActionHistory();

  // Add this flag to track if changes have been saved
  bool _changesSaved = true;

  void _recordAction(dynamic action) {
    _actionHistory.addAction(action);
    setState(() {
      hasUnsavedChanges = true;
      _changesSaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (hasUnsavedChanges) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text(
                  'You have unsaved changes. Are you sure you want to discard them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color.fromRGBO(24, 29, 32, 1),
            appBar: AppBar(
              title: const Text(
                'Faculty Management',
                style: TextStyle(
                  color: Color.fromRGBO(159, 160, 162, 1),
                  fontSize: 20,
                ),
              ),
              backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
              elevation: 0,
              actions: [
                if (hasUnsavedChanges)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(153, 55, 30, 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Color.fromRGBO(153, 55, 30, 1),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Unsaved changes',
                          style: TextStyle(
                            color: Color.fromRGBO(153, 55, 30, 1),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Mode',
                  onPressed: () {
                    setState(() {
                      isEditMode = !isEditMode;
                    });
                  },
                ),
                IconButton(
                  onPressed: _showSaveConfirmation,
                  icon: const Icon(
                    Icons.save,
                    color: Color.fromRGBO(153, 55, 30, 1),
                  ),
                  tooltip: 'Save Changes',
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.02,
                ),
                child: Column(
                  children: [
                    // Department Panel with fixed height
                    Container(
                      height: size.height * 0.15,
                      width: size.width,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(34, 39, 42, 1),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              size.width * 0.04,
                              8,
                              size.width * 0.04,
                              4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.category,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Departments',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Add Department Button
                                TextButton.icon(
                                  onPressed: _showAddDepartmentDialog,
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Color.fromRGBO(153, 55, 30, 1),
                                  ),
                                  label: const Text(
                                    'Add Department',
                                    style: TextStyle(
                                      color: Color.fromRGBO(153, 55, 30, 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: departments.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No departments added yet',
                                      style: TextStyle(
                                        color:
                                            Color.fromRGBO(159, 160, 162, 0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    itemCount: departments.length,
                                    itemBuilder: (context, index) {
                                      final department = departments[index];
                                      final isSelected =
                                          selectedDepartment == department;
                                      return _buildDepartmentItem(
                                          department, isSelected);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Faculty List Panel
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(34, 39, 42, 1),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                padding: EdgeInsets.all(size.width * 0.04),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(34, 39, 42, 1),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: accentColor.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selectedDepartment != null
                                          ? Icons.people
                                          : Icons.info_outline,
                                      color: accentColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        selectedDepartment ??
                                            'Select a department to view faculty',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (selectedDepartment != null)
                                      IconButton(
                                        onPressed: _showAddFaculty,
                                        icon: Icon(Icons.add_circle,
                                            color: accentColor),
                                      ),
                                  ],
                                ),
                              ),
                              // Faculty List
                              Expanded(
                                child: selectedDepartment != null
                                    ? StreamBuilder<List<Faculty>>(
                                        stream:
                                            _facultyDB.getFacultyByDepartment(
                                                selectedDepartment!),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'),
                                            );
                                          }

                                          if (!snapshot.hasData) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }

                                          final facultyList = snapshot.data!;

                                          return ListView.builder(
                                            padding:
                                                EdgeInsets.only(bottom: 100),
                                            itemCount: facultyList.length,
                                            itemBuilder: (context, index) {
                                              return _buildFacultyCard(
                                                  facultyList[index],
                                                  isEditMode);
                                            },
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.arrow_upward,
                                              color: accentColor,
                                              size: size.width * 0.12,
                                            ),
                                            SizedBox(
                                                height: size.height * 0.02),
                                            Text(
                                              'Select a department from above',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: size.width * 0.04,
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
                  ],
                ),
              ),
            ),
          ),
          if (isEditMode) _buildToolbox(),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddFaculty() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    DateTime? selectedDate;
    String selectedDesignation = 'Assistant Professor';

    final List<String> designations = [
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

    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: size.width * 0.9,
            maxHeight: size.height * 0.8,
          ),
          padding: EdgeInsets.all(size.width * 0.04),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_add, color: accentColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Add New Faculty',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Form fields with consistent styling
                _buildDialogTextField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                SizedBox(height: size.height * 0.02),
                // Add back the designation dropdown
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(24, 29, 32, 1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDesignation,
                      isExpanded: true,
                      dropdownColor: const Color.fromRGBO(24, 29, 32, 1),
                      style: const TextStyle(
                        color: Color.fromRGBO(159, 160, 162, 1),
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: accentColor),
                      items: designations.map((designation) {
                        bool isDisabled = designation == 'Dean' &&
                            _hasDean(selectedDepartment!);
                        return DropdownMenuItem<String>(
                          value: designation,
                          enabled: !isDisabled,
                          child: Row(
                            children: [
                              Icon(
                                getDesignationIcon(designation),
                                color: isDisabled ? Colors.grey : accentColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                designation,
                                style: TextStyle(
                                  color:
                                      isDisabled ? Colors.grey : Colors.white,
                                ),
                              ),
                              if (isDisabled)
                                Expanded(
                                  child: Text(
                                    ' (Already assigned)',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                )
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedDesignation = value);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                _buildDialogTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                SizedBox(height: size.height * 0.02),
                _buildDialogTextField(
                  controller: phoneController,
                  label: 'Phone',
                  icon: Icons.phone,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                SizedBox(height: size.height * 0.02),
                _buildDialogTextField(
                  controller: usernameController,
                  label: 'Username',
                  icon: Icons.account_circle,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                SizedBox(height: size.height * 0.02),
                _buildDialogTextField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                SizedBox(height: size.height * 0.02),
                // Date of Birth Picker
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: accentColor,
                              surface: const Color.fromRGBO(24, 29, 32, 1),
                              onSurface: const Color.fromRGBO(159, 160, 162, 1),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(24, 29, 32, 1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select Date of Birth',
                          style: const TextStyle(
                            color: Color.fromRGBO(159, 160, 162, 1),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color.fromRGBO(159, 160, 162, 0.7),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        List<String> errors = [];

                        // Validation checks
                        if (nameController.text.isEmpty) {
                          errors.add('Name is required');
                        }
                        if (!_isValidEmail(emailController.text)) {
                          errors.add('Invalid email address');
                        }
                        if (!_isValidPhone(phoneController.text)) {
                          errors.add('Invalid phone number');
                        }
                        if (!_isValidUsername(usernameController.text)) {
                          errors.add('Invalid username');
                        }
                        if (!_isValidPassword(passwordController.text)) {
                          errors.add('Invalid password');
                        }
                        if (selectedDate == null) {
                          errors.add('Date of birth is required');
                        }

                        // Check uniqueness for new faculty
                        final isUsernameUnique =
                            await _isUsernameUnique(usernameController.text);
                        final isEmailUnique =
                            await _isEmailUnique(emailController.text);
                        final isMobileUnique =
                            await _isMobileUnique(phoneController.text);

                        if (!isUsernameUnique) {
                          errors.add('Username already exists');
                        }
                        if (!isEmailUnique) {
                          errors.add('Email already exists');
                        }
                        if (!isMobileUnique) {
                          errors.add('Mobile number already exists');
                        }

                        if (errors.isNotEmpty) {
                          _showErrorDialog(errors);
                          return;
                        }

                        try {
                          setState(() {
                            _isSaving = true;
                          });

                          final newFaculty = Faculty(
                            name: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            department: selectedDepartment!,
                            username:
                                usernameController.text.toLowerCase().trim(),
                            password: passwordController.text,
                            dateOfBirth: selectedDate!,
                            designation: selectedDesignation,
                            experience: '',
                            qualifications: '',
                            subjects: [],
                          );

                          await _facultyDB.addFaculty(newFaculty);

                          // Record the add action
                          _recordAction(FacultyAddAction(
                            faculty: newFaculty,
                            department: selectedDepartment!,
                          ));

                          setState(() {
                            _isSaving = false;
                            hasUnsavedChanges = true;
                          });

                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Faculty added successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            _isSaving = false;
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add faculty: $e'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Add Faculty',
                              style: TextStyle(
                                color: Colors.white,
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
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    Color textColor = const Color.fromRGBO(159, 160, 162, 1),
    FormFieldValidator<String>? validator,
  }) {
    final ValueNotifier<bool> showPassword = ValueNotifier<bool>(!isPassword);
    final ValueNotifier<bool> hasError = ValueNotifier<bool>(false);
    final ValueNotifier<String?> errorText = ValueNotifier<String?>(null);

    return ValueListenableBuilder(
      valueListenable: showPassword,
      builder: (context, bool showText, _) {
        return TextFormField(
          controller: controller,
          obscureText: !showText,
          style: TextStyle(
            color: textColor,
          ),
          onChanged: (value) {
            errorText.value = _getErrorText(value, label);
            hasError.value = errorText.value != null;
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: hasError.value
                  ? const Color.fromRGBO(255, 82, 82, 1)
                  : const Color.fromRGBO(153, 55, 30, 1),
            ),
            filled: true,
            fillColor: const Color.fromRGBO(24, 29, 32, 1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError.value
                    ? const Color.fromRGBO(255, 82, 82, 0.3)
                    : const Color.fromRGBO(153, 55, 30, 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError.value
                    ? const Color.fromRGBO(255, 82, 82, 1)
                    : const Color.fromRGBO(153, 55, 30, 1),
                width: 2,
              ),
            ),
            prefixIcon: Icon(
              icon,
              color: hasError.value
                  ? const Color.fromRGBO(255, 82, 82, 1)
                  : const Color.fromRGBO(153, 55, 30, 1),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      showText ? Icons.visibility_off : Icons.visibility,
                      color: const Color.fromRGBO(153, 55, 30, 1),
                    ),
                    onPressed: () {
                      showPassword.value = !showText;
                    },
                  )
                : null,
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        );
      },
    );
  }

  Future<void> _showSaveConfirmation() async {
    if (!hasUnsavedChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save')),
      );
      return;
    }

    // Show confirmation dialog with changes summary
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Text(
          'Save Changes',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The following changes will be saved:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            ..._actionHistory._undoStack.map((action) {
              String description = '';
              if (action is DepartmentRenameAction) {
                description =
                    'Renamed department "${action.oldName}" to "${action.newName}"';
              } else if (action is DepartmentDeleteAction) {
                description = 'Deleted department "${action.departmentName}"';
              } else if (action is FacultyAddAction) {
                description = 'Added faculty "${action.faculty.name}"';
              } else if (action is FacultyDeleteAction) {
                description = 'Deleted faculty "${action.faculty.name}"';
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '• $description',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(159, 160, 162, 1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveChanges();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Confirm Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditFacultyDialog(Faculty faculty) {
    final nameController = TextEditingController(text: faculty.name);
    final emailController = TextEditingController(text: faculty.email);
    final phoneController = TextEditingController(text: faculty.phone);
    final usernameController = TextEditingController(text: faculty.username);
    final passwordController = TextEditingController(text: faculty.password);
    DateTime? selectedDate = faculty.dateOfBirth;
    String selectedDesignation = faculty.designation;

    final List<String> designations = [
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

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Color.fromRGBO(153, 55, 30, 1),
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Edit Faculty',
                      style: TextStyle(
                        color: Color.fromRGBO(159, 160, 162, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: phoneController,
                  label: 'Mobile Number',
                  icon: Icons.phone,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: usernameController,
                  label: 'Username',
                  icon: Icons.account_circle,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  textColor: const Color.fromRGBO(159, 160, 162, 1),
                ),
                const SizedBox(height: 16),
                // Add Designation Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(24, 29, 32, 1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDesignation,
                      isExpanded: true,
                      dropdownColor: const Color.fromRGBO(24, 29, 32, 1),
                      style: const TextStyle(
                          color: Color.fromRGBO(159, 160, 162, 1)),
                      items: designations.map((designation) {
                        return DropdownMenuItem<String>(
                          value: designation,
                          child: Text(designation),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedDesignation = value;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Date of Birth Picker
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color.fromRGBO(153, 55, 30, 1),
                              surface: Color.fromRGBO(34, 39, 42, 1),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(24, 29, 32, 1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select Date of Birth',
                          style: const TextStyle(
                            color: Color.fromRGBO(159, 160, 162, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color.fromRGBO(159, 160, 162, 0.7),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        List<String> errors = [];

                        // Validation checks
                        if (nameController.text.isEmpty) {
                          errors.add('Name is required');
                        }
                        if (!_isValidEmail(emailController.text)) {
                          errors.add('Invalid email address');
                        }
                        if (!_isValidPhone(phoneController.text)) {
                          errors.add('Invalid phone number');
                        }
                        if (!_isValidUsername(usernameController.text)) {
                          errors.add('Invalid username');
                        }
                        if (!_isValidPassword(passwordController.text)) {
                          errors.add('Invalid password');
                        }
                        if (selectedDate == null) {
                          errors.add('Date of birth is required');
                        }

                        // Check uniqueness excluding current faculty
                        final isUsernameUnique = await _isUsernameUnique(
                          usernameController.text,
                          excludeId: faculty.id,
                        );
                        final isEmailUnique = await _isEmailUnique(
                          emailController.text,
                          excludeId: faculty.id,
                        );
                        final isMobileUnique = await _isMobileUnique(
                          phoneController.text,
                          excludeId: faculty.id,
                        );

                        if (!isUsernameUnique) {
                          errors.add('Username already exists');
                        }
                        if (!isEmailUnique) {
                          errors.add('Email already exists');
                        }
                        if (!isMobileUnique) {
                          errors.add('Mobile number already exists');
                        }

                        if (errors.isNotEmpty) {
                          _showErrorDialog(errors);
                          return;
                        }

                        final updatedFaculty = Faculty(
                          id: faculty.id,
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          department: faculty.department,
                          username: usernameController.text,
                          password: passwordController.text,
                          dateOfBirth: selectedDate!,
                          designation: selectedDesignation,
                          experience: faculty.experience,
                          qualifications: faculty.qualifications,
                          subjects: faculty.subjects,
                        );

                        await _facultyDB.updateFaculty(updatedFaculty);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
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
      ),
    );
  }

  void _showAddDepartmentDialog() {
    final TextEditingController departmentController = TextEditingController();
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: size.width * 0.8,
            maxHeight: size.height * 0.4,
          ),
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.add_business,
                    color: Color.fromRGBO(153, 55, 30, 1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add New Department',
                    style: TextStyle(
                      color: Color.fromRGBO(159, 160, 162, 1),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: _buildDialogTextField(
                    controller: departmentController,
                    label: 'Department Name',
                    icon: Icons.category,
                    textColor: const Color.fromRGBO(159, 160, 162, 1),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Department name is required';
                      }
                      if (departments.contains(value)) {
                        return 'Department already exists';
                      }
                      if (value.length < 3) return 'Name too short';
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                        return 'Only letters and spaces allowed';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style:
                          TextStyle(color: Color.fromRGBO(159, 160, 162, 0.7)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final deptName = departmentController.text.trim();
                      final error = _validateDepartmentName(deptName);

                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        await _departmentDB.addDepartment(deptName);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Department added successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add department: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Department'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateDepartmentName(String name) {
    if (name.isEmpty) return 'Department name is required';
    if (departments.contains(name)) return 'Department already exists';
    if (name.length < 3) return 'Department name too short';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Only letters and spaces allowed';
    }
    return null;
  }

  void _showDeleteFacultyConfirmation(Faculty faculty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Text(
          'Delete Faculty',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${faculty.name}?',
          style: const TextStyle(
            color: Color.fromRGBO(159, 160, 162, 1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color.fromRGBO(159, 160, 162, 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Record the delete action before deleting
                _recordAction(FacultyDeleteAction(
                  faculty: faculty,
                  department: faculty.department,
                ));

                await _facultyDB.deleteFaculty(faculty.id!);

                setState(() {
                  facultyData[selectedDepartment]?.remove(faculty);
                });

                Navigator.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete faculty: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(255, 82, 82, 1),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyCard(Faculty faculty, bool isEditMode) {
    // Get icon and color based on designation
    IconData getDesignationIcon() {
      switch (faculty.designation) {
        case 'Dean':
          return Icons.school; // Academic cap icon
        case 'Head of Department':
          return Icons.account_balance; // Building icon
        case 'Professor':
          return Icons.psychology; // Brain/knowledge icon
        case 'Associate Professor':
          return Icons.menu_book; // Book icon
        case 'Assistant Professor':
          return Icons.person_outline; // Person icon
        case 'Guest Faculty':
          return Icons.card_membership; // Card icon
        case 'Visiting Faculty':
          return Icons.directions_walk; // Walking person icon
        case 'Research Associate':
          return Icons.science; // Lab icon
        case 'Lab Assistant':
          return Icons.computer; // Computer icon
        default:
          return Icons.person;
      }
    }

    Color getDesignationColor() {
      switch (faculty.designation) {
        case 'Dean':
          return Colors.amber;
        case 'Head of Department':
          return Colors.purple;
        case 'Professor':
          return Colors.blue;
        case 'Associate Professor':
          return Colors.green;
        default:
          return accentColor;
      }
    }

    final designationColor = getDesignationColor();
    final designationIcon = getDesignationIcon();
    final isDean = faculty.designation == 'Dean';

    return InkWell(
      onTap: () => _showFacultyDetails(faculty),
      child: Card(
        color: const Color.fromRGBO(34, 39, 42, 1), // Change the card color
        elevation: isDean ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isEditMode ? Colors.blue : designationColor.withOpacity(0.5),
            width: isDean ? 2 : 1,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: designationColor.withOpacity(0.2),
            child: Icon(
              designationIcon,
              color: designationColor,
            ),
          ),
          title: Row(
            children: [
              Text(faculty.name, style: const TextStyle(color: Colors.white)),
              if (isDean)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Text(
                    'Dean',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(faculty.department,
                  style: const TextStyle(color: Colors.white70)),
              Text(
                isDean ? 'Dean of ${faculty.department}' : faculty.designation,
                style: TextStyle(
                  color: isDean ? Colors.amber : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          trailing: isEditMode
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditFacultyDialog(faculty),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteFacultyConfirmation(faculty),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  void _showDeanDeleteWarning(Faculty faculty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.amber),
            SizedBox(width: 8),
            Text('Delete Dean'),
          ],
        ),
        content: Text(
          'Warning: You are about to remove the Dean of ${faculty.department}. '
          'This action requires special authorization.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Add authorization check here if needed
              _showDeleteFacultyConfirmation(faculty);
              Navigator.pop(context);
            },
            child: Text('Proceed with Deletion'),
          ),
        ],
      ),
    );
  }

  bool _hasDean(String department) {
    return facultyData[department]
            ?.any((faculty) => faculty.designation == 'Dean') ??
        false;
  }

  void _showFacultyDetails(Faculty faculty) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailHeader(faculty),
                  const Divider(color: Colors.grey),
                  _buildDetailsList(faculty),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailHeader(Faculty faculty) => Row(
        children: [
          Icon(getDesignationIcon(faculty.designation), color: accentColor),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
            faculty.name,
            style: const TextStyle(/*...*/),
          )),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );

  Widget _buildDetailsList(Faculty faculty) => ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDetailItem('Designation', faculty.designation),
          _buildDetailItem('Department', faculty.department),
          _buildDetailItem('Experience', faculty.experience),
          _buildDetailItem('Qualifications', faculty.qualifications),
          _buildDetailItem('Subjects', faculty.subjects.join(", ")),
          _buildDetailItem('Email', faculty.email),
          _buildDetailItem('Phone', faculty.phone),
          _buildDetailItem('Username', faculty.username),
          _buildDetailItem('Date of Birth',
              '${faculty.dateOfBirth.day}/${faculty.dateOfBirth.month}/${faculty.dateOfBirth.year}'),
        ],
      );

  Widget _buildDetailItem(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildToolbox() {
    return Positioned(
      bottom: 80,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(34, 39, 42, 1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showEditDepartmentDialog(),
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            IconButton(
              onPressed: () => _showDepartmentDeleteConfirmation(),
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDepartmentDialog() {
    if (selectedDepartment == null) return;

    final nameController = TextEditingController(text: selectedDepartment);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Department Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter new department name',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != selectedDepartment) {
                try {
                  // Get all faculty in the department
                  final facultyList = await _facultyDB
                      .getFacultyByDepartment(selectedDepartment!)
                      .first;

                  // Create new faculty objects with updated department
                  for (var faculty in facultyList) {
                    final updatedFaculty = Faculty(
                      id: faculty.id,
                      name: faculty.name,
                      email: faculty.email,
                      phone: faculty.phone,
                      department: newName,
                      username: faculty.username,
                      password: faculty.password,
                      dateOfBirth: faculty.dateOfBirth,
                      designation: faculty.designation,
                      experience: faculty.experience,
                      qualifications: faculty.qualifications,
                      subjects: faculty.subjects,
                    );

                    // Record the update action
                    _recordAction(FacultyEditAction(
                      oldFaculty: faculty,
                      newFaculty: updatedFaculty,
                    ));
                  }

                  // Record department rename action
                  _recordAction(DepartmentRenameAction(
                    oldName: selectedDepartment!,
                    newName: newName,
                  ));

                  setState(() {
                    // Update local state
                    final index = departments.indexOf(selectedDepartment!);
                    departments[index] = newName;
                    facultyData[newName] = facultyData[selectedDepartment]!;
                    facultyData.remove(selectedDepartment);
                    selectedDepartment = newName;
                    hasUnsavedChanges = true;
                  });

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating department: $e')),
                  );
                }
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDepartmentDeleteConfirmation() {
    if (selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a department to delete')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Text(
          'Delete Department',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this department? This will also delete all faculty members in this department.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromRGBO(159, 160, 162, 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteDepartmentAndFaculty(selectedDepartment!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _undoLastAction() {
    if (_changesSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to undo - changes have been saved'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final action = _actionHistory.undo();
    if (action != null) {
      setState(() {
        hasUnsavedChanges = true;
        _changesSaved = false;
        switch (action.runtimeType) {
          case DepartmentRenameAction:
            final renameAction = action as DepartmentRenameAction;
            departments[departments.indexOf(renameAction.newName)] =
                renameAction.oldName;
            break;
          case DepartmentDeleteAction:
            final deleteAction = action as DepartmentDeleteAction;
            departments.add(deleteAction.departmentName);
            break;
          case FacultyAddAction:
            final addAction = action as FacultyAddAction;
            facultyData[selectedDepartment]?.remove(
                facultyData[selectedDepartment]
                    ?.firstWhere((f) => f.id == addAction.faculty.id));
            break;
          case FacultyDeleteAction:
            final deleteAction = action as FacultyDeleteAction;
            facultyData[selectedDepartment]?.add(deleteAction.faculty);
            break;
          case FacultyEditAction:
            final editAction = action as FacultyEditAction;
            final index = facultyData[selectedDepartment]
                ?.indexWhere((f) => f.id == editAction.oldFaculty.id);
            if (index != null && index != -1) {
              facultyData[selectedDepartment]?[index] = editAction.oldFaculty;
            }
            break;
        }
      });
    }
  }

  void _redoLastAction() {
    if (_changesSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to redo - changes have been saved'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final action = _actionHistory.redo();
    if (action != null) {
      setState(() {
        hasUnsavedChanges = true;
        _changesSaved = false;
        switch (action.runtimeType) {
          case DepartmentRenameAction:
            final renameAction = action as DepartmentRenameAction;
            departments[departments.indexOf(renameAction.oldName)] =
                renameAction.newName;
            break;
          case DepartmentDeleteAction:
            final deleteAction = action as DepartmentDeleteAction;
            departments.remove(deleteAction.departmentName);
            break;
          case FacultyAddAction:
            final addAction = action as FacultyAddAction;
            final facultyToAdd = facultyData[selectedDepartment]
                ?.firstWhere((f) => f.id == addAction.faculty.id);
            if (facultyToAdd != null) {
              facultyData[selectedDepartment]?.add(facultyToAdd);
            }
            break;
          case FacultyDeleteAction:
            final deleteAction = action as FacultyDeleteAction;
            facultyData[selectedDepartment]?.remove(deleteAction.faculty);
            break;
          case FacultyEditAction:
            final editAction = action as FacultyEditAction;
            final index = facultyData[selectedDepartment]
                ?.indexWhere((f) => f.id == editAction.oldFaculty.id);
            if (index != null && index != -1) {
              facultyData[selectedDepartment]?[index] = editAction.newFaculty;
            }
            break;
        }
      });
    }
  }

  // Update the department deletion dialog
  void _showDeleteDepartmentDialog(String department) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Text('Delete Department',
            style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this department?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              await _deleteDepartmentAndFaculty(department);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        print('Attempting to delete department: $department'); // Debugging line
        await _departmentDB.deleteDepartment(department);
        print('Department deleted successfully'); // Debugging line

        // Delete all faculty associated with this department
        final facultyList =
            await _facultyDB.getFacultyByDepartment(department).first;
        for (var faculty in facultyList) {
          if (faculty.id != null) {
            await _facultyDB.deleteFaculty(faculty.id!);
          }
        }

        // Update local state
        setState(() {
          departments.remove(department);
          facultyData.remove(department);
          if (selectedDepartment == department) {
            selectedDepartment = null;
          }
          hasUnsavedChanges = true;
        });

        // Record the delete action
        _recordAction(DepartmentDeleteAction(departmentName: department));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Department "$department" deleted successfully')),
        );
      } catch (e) {
        print('Error deleting department: $e'); // Debugging line
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting department: $e')),
        );
      }
    }
  }

  // Add this method to delete all faculty in a department
  Future<void> _deleteDepartmentAndFaculty(String department) async {
    try {
      print(
          'Starting department deletion process for: $department'); // Debug log

      // Get faculty list before deletion
      final facultyList =
          await _facultyDB.getFacultyByDepartment(department).first;

      // Delete the department and its faculty from the database
      await _facultyDB.deleteDepartment(department);

      print('Department deleted from database'); // Debug log

      // Record the delete actions for undo/redo
      _recordAction(DepartmentDeleteAction(departmentName: department));
      for (var faculty in facultyList) {
        _recordAction(
            FacultyDeleteAction(faculty: faculty, department: department));
      }

      // Update local state
      setState(() {
        departments.remove(department);
        facultyData.remove(department);
        if (selectedDepartment == department) {
          selectedDepartment = null;
        }
        hasUnsavedChanges = true;
        _changesSaved = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Department and associated faculty deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error in department deletion: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete department: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add this method to handle back navigation
  Future<bool> _onWillPop() async {
    if (hasUnsavedChanges) {
      // Show the save confirmation dialog
      await _showSaveConfirmation();
      // Stay on the page until the user explicitly chooses to leave
      return false;
    }
    return true; // No unsaved changes, ok to leave
  }

  Future<void> _saveChanges() async {
    try {
      // Save all changes to the database
      for (var facultyList in facultyData.values) {
        for (var faculty in facultyList) {
          await _facultyDB.updateFaculty(faculty);
        }
      }

      // Clear the action history after saving
      _actionHistory.clear();
      setState(() {
        hasUnsavedChanges = false;
        _changesSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All changes saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add this widget to show loading state
  Widget _buildLoadingOverlay() {
    return _isSaving
        ? Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(153, 55, 30, 1),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}

// Extract add department button to separate widget
class AddDepartmentButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddDepartmentButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 50,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(24, 29, 32, 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromRGBO(153, 55, 30, 0.3),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add_circle,
                color: Color.fromRGBO(153, 55, 30, 1),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
