import 'package:flutter/material.dart';
import '../models/faculty.dart';

class FacultyManagement extends StatefulWidget {
  const FacultyManagement({super.key});

  @override
  State<FacultyManagement> createState() => _FacultyManagementState();
}

class _FacultyManagementState extends State<FacultyManagement> {
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);

  final List<String> departments = [
    'Computer Science',
    'Commerce',
    'Management',
    'Science',
    'Languages',
  ];
  String? selectedDepartment;
  bool hasUnsavedChanges = false;

  final Map<String, List<Faculty>> facultyData = {};

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
    // Initialize all department lists at start
    for (var department in departments) {
      if (facultyData[department] == null) {
        facultyData[department] = [];
      }
    }
  }

  // Add key for ListView
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  // Cache department items
  final Map<String, Widget> _departmentItemCache = {};

  // Optimize department item building
  Widget _buildDepartmentItem(String department, bool isSelected) {
    // Return cached item if exists
    final cacheKey = '$department-$isSelected';
    if (_departmentItemCache.containsKey(cacheKey)) {
      return _departmentItemCache[cacheKey]!;
    }

    final item = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (mounted) {
              setState(() {
                selectedDepartment = department;
                facultyData[department] ??= [];
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor
                  : const Color.fromRGBO(24, 29, 32, 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accentColor : accentColor.withOpacity(0.3),
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
                    color: const Color.fromRGBO(159, 160, 162, 1),
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Cache the built item
    _departmentItemCache[cacheKey] = item;
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  SizedBox(width: 4),
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
            onPressed: _showSaveConfirmation,
            icon: const Icon(
              Icons.save,
              color: Color.fromRGBO(153, 55, 30, 1),
            ),
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Panel - Department Selection
            Container(
              height: 100,
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category,
                          color: Color.fromRGBO(153, 55, 30, 1),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Select Department',
                          style: TextStyle(
                            color: Color.fromRGBO(159, 160, 162, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      key: _listKey,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: departments.length + 1,
                      itemBuilder: (context, index) {
                        if (index == departments.length) {
                          return AddDepartmentButton(
                              onTap: _showAddDepartmentDialog);
                        }
                        final department = departments[index];
                        final isSelected = selectedDepartment == department;
                        return _buildDepartmentItem(department, isSelected);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bottom Panel - Faculty List
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            selectedDepartment != null
                                ? Icons.people
                                : Icons.info_outline,
                            color: const Color.fromRGBO(153, 55, 30, 1),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedDepartment ??
                                'Select a department to view faculty',
                            style: const TextStyle(
                              color: Color.fromRGBO(159, 160, 162, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (selectedDepartment != null)
                            IconButton(
                              onPressed: _showAddFaculty,
                              icon: const Icon(
                                Icons.add_circle,
                                color: Color.fromRGBO(153, 55, 30, 1),
                              ),
                              tooltip: 'Add Faculty',
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: selectedDepartment != null
                          ? ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  facultyData[selectedDepartment]?.length ?? 0,
                              itemBuilder: (context, index) {
                                final facultyList =
                                    facultyData[selectedDepartment];
                                if (facultyList == null ||
                                    facultyList.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No faculty members yet',
                                      style: TextStyle(
                                        color:
                                            Color.fromRGBO(159, 160, 162, 0.7),
                                      ),
                                    ),
                                  );
                                }
                                final faculty = facultyList[index];
                                return _buildFacultyCard(faculty);
                              },
                            )
                          : const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: Color.fromRGBO(153, 55, 30, 1),
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Select a department from above',
                                    style: TextStyle(
                                      color: Color.fromRGBO(159, 160, 162, 0.7),
                                      fontSize: 16,
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
          ],
        ),
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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 16),
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
                                  designation == 'Dean'
                                      ? Icons.stars
                                      : designation == 'Head of Department'
                                          ? Icons.account_balance
                                          : Icons.person,
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
                                  ),
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
                  SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email,
                    textColor: const Color.fromRGBO(159, 160, 162, 1),
                  ),
                  SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: phoneController,
                    label: 'Phone',
                    icon: Icons.phone,
                    textColor: const Color.fromRGBO(159, 160, 162, 1),
                  ),
                  SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: usernameController,
                    label: 'Username',
                    icon: Icons.account_circle,
                    textColor: const Color.fromRGBO(159, 160, 162, 1),
                  ),
                  SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    textColor: const Color.fromRGBO(159, 160, 162, 1),
                  ),
                  SizedBox(height: 16),
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
                                onSurface:
                                    const Color.fromRGBO(159, 160, 162, 1),
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
                            style: TextStyle(
                              color: const Color.fromRGBO(159, 160, 162, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: const Color.fromRGBO(159, 160, 162, 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          List<String> errors = [];
                          if (nameController.text.isEmpty)
                            errors.add('Name is required');
                          if (!_isValidEmail(emailController.text))
                            errors.add('Invalid email');
                          if (!_isValidPhone(phoneController.text))
                            errors.add('Invalid phone number');
                          if (!_isValidUsername(usernameController.text))
                            errors.add('Invalid username');
                          if (!_isValidPassword(passwordController.text))
                            errors.add('Invalid password');
                          if (selectedDate == null)
                            errors.add('Date of birth is required');

                          if (errors.isNotEmpty) {
                            _showErrorDialog(errors);
                            return;
                          }

                          final newFaculty = Faculty(
                            name: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            department: selectedDepartment!,
                            username: usernameController.text,
                            password: passwordController.text,
                            dateOfBirth: selectedDate!,
                            designation: selectedDesignation,
                          );

                          setState(() {
                            facultyData[selectedDepartment!] ??= [];
                            facultyData[selectedDepartment!]!.add(newFaculty);
                            hasUnsavedChanges = true;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
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
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    Color textColor = const Color.fromRGBO(159, 160, 162, 1),
  }) {
    final ValueNotifier<bool> showPassword = ValueNotifier<bool>(!isPassword);
    final ValueNotifier<bool> hasError = ValueNotifier<bool>(false);
    final ValueNotifier<String?> errorText = ValueNotifier<String?>(null);

    return ValueListenableBuilder(
      valueListenable: showPassword,
      builder: (context, bool showText, _) {
        return TextField(
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
        );
      },
    );
  }

  void _showSaveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Row(
          children: [
            Icon(
              Icons.save,
              color: Color.fromRGBO(153, 55, 30, 1),
            ),
            SizedBox(width: 8),
            Text(
              'Save Changes',
              style: TextStyle(
                color: Color.fromRGBO(159, 160, 162, 1),
              ),
            ),
          ],
        ),
        content: const Text(
          'Do you want to save the current changes?',
          style: TextStyle(
            color: Color.fromRGBO(159, 160, 162, 1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color.fromRGBO(159, 160, 162, 0.7),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                hasUnsavedChanges = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Changes saved successfully!'),
                  backgroundColor: Color.fromRGBO(153, 55, 30, 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(
              Icons.save,
              color: Colors.white,
            ),
            label: const Text(
              'Save',
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

  void _showEditFacultyDialog(Faculty faculty) {
    final nameController = TextEditingController(text: faculty.name);
    final emailController = TextEditingController(text: faculty.email);
    final phoneController = TextEditingController(text: faculty.phone);
    final usernameController = TextEditingController(text: faculty.username);
    final passwordController = TextEditingController(text: faculty.password);
    DateTime? selectedDate = faculty.dateOfBirth;

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
                        const SizedBox(width: 12),
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
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color.fromRGBO(159, 160, 162, 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            emailController.text.isNotEmpty &&
                            phoneController.text.isNotEmpty &&
                            usernameController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty &&
                            selectedDate != null) {
                          setState(() {
                            final index = facultyData[selectedDepartment!]!
                                .indexOf(faculty);
                            facultyData[selectedDepartment!]![index] = Faculty(
                              name: nameController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              department: selectedDepartment!,
                              username: usernameController.text,
                              password: passwordController.text,
                              dateOfBirth: selectedDate!,
                              designation: faculty.designation,
                            );
                            hasUnsavedChanges = true;
                          });
                          Navigator.pop(context);
                        }
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
              _buildDialogTextField(
                controller: departmentController,
                label: 'Department Name',
                icon: Icons.category,
                textColor: const Color.fromRGBO(159, 160, 162, 1),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color.fromRGBO(159, 160, 162, 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (departmentController.text.isNotEmpty) {
                        setState(() {
                          departments.add(departmentController.text);
                          selectedDepartment = departmentController.text;
                          hasUnsavedChanges = true;
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Add Department',
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
    );
  }

  void _showDeleteConfirmation(Faculty faculty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Row(
          children: [
            Icon(
              Icons.warning,
              color: Color.fromRGBO(255, 82, 82, 1),
            ),
            SizedBox(width: 8),
            Text(
              'Delete Faculty',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${faculty.name}?',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color.fromRGBO(159, 160, 162, 0.7),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                facultyData[selectedDepartment!]!.remove(faculty);
                hasUnsavedChanges = true;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(255, 82, 82, 1),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyCard(Faculty faculty) {
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
        elevation: isDean ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: designationColor.withOpacity(0.5),
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
              Text(faculty.name),
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
              Text(faculty.department),
              Text(
                isDean ? 'Dean of ${faculty.department}' : faculty.designation,
                style: TextStyle(
                  color: isDean ? Colors.amber : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showEditFacultyDialog(faculty),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: isDean
                    ? () => _showDeanDeleteWarning(faculty)
                    : () => _showDeleteConfirmation(faculty),
              ),
            ],
          ),
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
              _showDeleteConfirmation(faculty);
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
          _buildDetailItem('Email', faculty.email),
          _buildDetailItem('Phone', faculty.phone),
          _buildDetailItem('Username', faculty.username),
          _buildDetailItem('Date of Birth',
              '${faculty.dateOfBirth.day}/${faculty.dateOfBirth.month}/${faculty.dateOfBirth.year}'),
        ],
      );

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color.fromRGBO(159, 160, 162, 1),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Extract add department button to separate widget
class AddDepartmentButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddDepartmentButton({Key? key, required this.onTap}) : super(key: key);

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