import 'package:flutter/material.dart';
import 'pages/unavailability_page.dart';
import 'faculty/settings_page.dart';
import 'faculty/faculty_profile_page.dart';

class FacultyDashboard extends StatefulWidget {
  final String facultyName;
  final String department;

  const FacultyDashboard({
    super.key,
    required this.facultyName,
    required this.department,
  });

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

// Add this class to store request details
class UnavailabilityRequest {
  final DateTime date;
  final List<String> periods;
  final List<String> classes; // Store class names
  final double totalHours;
  final Map<String, String> replacements; // Store faculty-class mapping
  final String status;

  UnavailabilityRequest({
    required this.date,
    required this.periods,
    required this.classes,
    required this.totalHours,
    required this.replacements, // {class_name: faculty_name}
    required this.status,
  });
}

class CoverageNotification {
  final DateTime date;
  final String className;
  final String period;
  final String acceptedFaculty;
  final DateTime acceptedTime;

  CoverageNotification({
    required this.date,
    required this.className,
    required this.period,
    required this.acceptedFaculty,
    required this.acceptedTime,
  });
}

class CoverageRequest {
  final String requestingFaculty;
  final DateTime date;
  final Map<String, String> periodClassMap; // Map of period -> class name
  final List<String> availablePeriods;
  final bool isLab;
  final DateTime requestTime;

  CoverageRequest({
    required this.requestingFaculty,
    required this.date,
    required this.periodClassMap,
    required this.availablePeriods,
    required this.isLab,
    required this.requestTime,
  });
}

class _FacultyDashboardState extends State<FacultyDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late double screenWidth;
  late double screenHeight;

  // Define colors
  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  final List<String> timeSlots = [
    '8:50 - 9:40', // Period 0 (optional)
    '9:45 - 10:35', // Period 1
    '10:40 - 11:30', // Period 2
    '11:35 - 12:25', // Period 3
    '1:05 - 1:55', // Period 4
    '2:00 - 2:50', // Period 5
    '2:55 - 3:45', // Period 6
    '3:50 - 4:40', // Period 7 (optional)
  ];

  // Add helper method to check if period is optional
  bool isOptionalPeriod(int periodIndex) {
    return periodIndex == 0 || periodIndex == 7;
  }

  Map<String, List<int>> unavailablePeriods = {};

  // Replace requests list with notifications
  List<CoverageNotification> coverageNotifications = [];

  // Add this to store incoming requests
  List<CoverageRequest> incomingRequests = [
    CoverageRequest(
      requestingFaculty: 'Dr. Sarah',
      date: DateTime.now().add(Duration(days: 1)),
      periodClassMap: {
        '8:50 - 9:40': 'III BSc A',
        '9:45 - 10:35': 'II BCA B',
        '10:40 - 11:30': 'I BSc C',
      },
      availablePeriods: ['8:50 - 9:40', '10:40 - 11:30'],
      isLab: false,
      requestTime: DateTime.now(),
    ),
    CoverageRequest(
      requestingFaculty: 'Prof. John',
      date: DateTime.now(),
      periodClassMap: {
        '9:45 - 10:35': 'II BCA A (Lab)',
        '10:40 - 11:30': 'II BCA A (Lab)',
      },
      availablePeriods: ['9:45 - 10:35', '10:40 - 11:30'],
      isLab: true,
      requestTime: DateTime.now().subtract(Duration(hours: 1)),
    ),
  ];

  // TODO: Implement Firebase integration for lab schedules
  // Lab schedules should be fetched from Firebase and merged with regular class schedule
  // Structure in Firebase should include:
  // - Lab subject
  // - Duration (typically 4 periods)
  // - Lab room
  // - Student batch/section

  Map<String, Map<int, String>> classSchedule = {
    'Monday': {
      0: 'I BSc B (Lab)', // Morning lab session
      1: 'I BSc B (Lab)',
      2: 'I BSc B (Lab)',
      3: 'I BSc B (Lab)',
      4: 'III BCA B',
      5: 'I BSc C',
    },
    'Tuesday': {
      1: 'II BCA A',
      2: 'III BSc B',
      3: 'I BCA C',
      4: 'II BSc A (Lab)', // Afternoon lab session
      5: 'II BSc A (Lab)',
    },
    'Wednesday': {
      0: 'III BCA A',
      1: 'I BSc B',
      2: 'II BCA B',
      3: 'III BSc A',
      4: 'I BCA A (Lab)', // Afternoon lab session
      5: 'I BCA A (Lab)',
    },
    'Thursday': {
      1: 'II BSc B',
      2: 'III BCA C',
      3: 'II BCA C',
      4: 'I BSc A (Lab)', // Afternoon lab session
      5: 'I BSc A (Lab)',
    },
    'Friday': {
      0: 'III BSc C',
      1: 'II BCA B',
      2: 'I BSc A',
      3: 'III BCA B (Lab)', // Afternoon lab session
      4: 'III BCA B (Lab)',
      5: 'II BSc C',
    },
    'Saturday': {
      0: 'III BSc A',
      1: 'II BCA B',
      2: 'I BSc C',
    },
  };

  bool shouldShowPeriod(String day, int periodIndex, bool isLab) {
    // For Saturday, only show first 3 periods
    if (day == 'Saturday') {
      return periodIndex <= 3;
    }

    // For lab sessions that extend beyond regular hours
    if (isLab) {
      // Morning lab (0-3) or Afternoon lab (4-7)
      if (periodIndex >= 0 && periodIndex <= 3) {
        return true;
      }
      if (periodIndex >= 4 && periodIndex <= 5) {
        return true;
      }
    }

    // Regular periods (0-5)
    return periodIndex <= 5;
  }

  Map<CoverageRequest, String> requestStatus =
      {}; // Stores request -> status mapping

  List<CoverageRequest> declinedRequests = []; // Store declined requests

  // Add these variables to store faculty profile data
  late String _facultyName;
  late String _designation;
  late String _experience;
  late String _qualifications;
  late List<String> _subjects;
  late String _email;
  late String _phone;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize with default values
    // TODO: Fetch these values from Firebase/database
    _facultyName = widget.facultyName;
    _designation = 'Associate Professor';
    _experience = '8+ Years';
    _qualifications = 'Ph.D in Computer Science\nM.Tech in Computer Science';
    _subjects = ['Machine Learning', 'Data Structures', 'Algorithms'];
    _email = 'faculty@example.com';
    _phone = '+91 9876543210';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isLabPeriod(String day, int periodIndex) {
    final schedule = classSchedule[day];
    if (schedule == null) return false;

    // Check if current period is marked as lab
    final currentClass = schedule[periodIndex];
    if (currentClass == null) return false;

    if (currentClass.contains('Lab')) {
      // Verify if it's part of a 4-period block
      // Morning lab block (0-3) or afternoon lab block (4-7)
      if (periodIndex >= 0 && periodIndex <= 3) {
        // Check if all morning periods are same lab
        return schedule[0] == currentClass &&
            schedule[1] == currentClass &&
            schedule[2] == currentClass &&
            schedule[3] == currentClass;
      } else if (periodIndex >= 4 && periodIndex <= 7) {
        // Check if all afternoon periods are same lab
        return schedule[4] == currentClass &&
            schedule[5] == currentClass &&
            schedule[6] == currentClass &&
            schedule[7] == currentClass;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize screen dimensions at build time
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FacultyProfilePage(
                      facultyName: _facultyName,
                      department: widget.department,
                      designation: _designation,
                      experience: _experience,
                      qualifications: _qualifications,
                      subjects: _subjects,
                      email: _email,
                      phone: _phone,
                    ),
                  ),
                );
              });
            },
            child: CircleAvatar(
              backgroundColor: accentColor,
              child: Text(
                _facultyName.substring(0, 1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _facultyName,
              style: TextStyle(
                color: textColor,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.department,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: screenWidth * 0.03,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined, color: textColor),
                if (requestStatus.entries
                            .where((e) => e.value == 'accepted')
                            .length +
                        declinedRequests.length >
                    0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        (requestStatus.entries
                                    .where((e) => e.value == 'accepted')
                                    .length +
                                declinedRequests.length)
                            .toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.025,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showNotificationHistory,
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textColor),
            onPressed: () async {
              try {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FacultySettingsPage(
                      facultyName: _facultyName,
                      department: widget.department,
                      designation: _designation,
                      experience: _experience,
                      qualifications: _qualifications,
                      subjects: _subjects,
                      email: _email,
                      phone: _phone,
                      profileImageUrl: _profileImageUrl,
                      onChanged: (value) {
                        setState(() {
                          _designation = value;
                        });
                      },
                    ),
                  ),
                );

                if (result != null && mounted) {
                  setState(() {
                    _facultyName = result['name'];
                    _designation = result['designation'];
                    _experience = result['experience'];
                    _qualifications = result['qualifications'];
                    _subjects = (result['subjects'] as String)
                        .split(',')
                        .map((e) => e.trim())
                        .toList();
                    _email = result['email'];
                    _phone = result['phone'];
                    _profileImageUrl = result['profileImageUrl'];
                  });

                  // Rebuild the UI immediately
                  if (mounted) {
                    setState(() {});
                  }
                }
              } catch (e) {
                print('Error navigating to settings: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02), // Add top padding
            _buildTodaySchedule(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Main Content - Compact Unavailability Card
                  Container(
                    height: screenHeight * 0.12,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openUnavailabilityPage(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.event_busy,
                                  color: accentColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mark Unavailability',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'View and update your schedule',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: screenWidth * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: accentColor,
                                size: screenWidth * 0.035,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Recent Requests Section
                  if (coverageNotifications.isNotEmpty) ...[
                    const Text(
                      'Coverage Notifications',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...coverageNotifications.map(
                        (notification) => _buildNotificationCard(notification)),
                  ],

                  if (incomingRequests.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Coverage Requests',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...incomingRequests
                        .map((request) => _buildIncomingRequestCard(request)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(CoverageNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${notification.date.day}/${notification.date.month}/${notification.date.year}',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                timeAgo(notification.acceptedTime),
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: screenWidth * 0.03,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: textColor),
                    children: [
                      TextSpan(
                        text: notification.acceptedFaculty,
                        style: const TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const TextSpan(
                        text: ' will cover your ',
                        style: TextStyle(fontSize: 14),
                      ),
                      TextSpan(
                        text: notification.className,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: ' class (${notification.period})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestCard(CoverageRequest request) {
    List<String> selectedPeriods = [];

    void showConflictWarning(String period, Function() onConfirm) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            'Schedule Conflict',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'You have a class during this period. Are you sure you want to accept it?',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: textColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              child: Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return StatefulBuilder(
      builder: (context, setState) => Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius:
              BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
          border: Border.all(color: accentColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: MediaQuery.of(context).size.width * 0.02,
              offset: Offset(0, MediaQuery.of(context).size.height * 0.005),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.015,
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor.withOpacity(0.8), accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft:
                      Radius.circular(MediaQuery.of(context).size.width * 0.05),
                  topRight:
                      Radius.circular(MediaQuery.of(context).size.width * 0.05),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.04,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      request.requestingFaculty[0],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.requestingFaculty,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeAgo(request.requestTime),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                      vertical: MediaQuery.of(context).size.height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.03),
                    ),
                    child: Text(
                      '${request.date.day}/${request.date.month}/${request.date.year}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Period chips
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select periods to cover:',
                    style: TextStyle(
                      color: textColor,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: MediaQuery.of(context).size.width * 0.02,
                    runSpacing: MediaQuery.of(context).size.width * 0.02,
                    children: request.periodClassMap.entries.map((entry) {
                      final period = entry.key;
                      final className = entry.value;
                      final isAvailable =
                          request.availablePeriods.contains(period);
                      final isSelected = selectedPeriods.contains(period);

                      return InkWell(
                        onTap: () {
                          if (!isAvailable) {
                            showConflictWarning(period, () {
                              setState(() {
                                if (isSelected) {
                                  selectedPeriods.remove(period);
                                } else {
                                  selectedPeriods.add(period);
                                }
                              });
                            });
                          } else {
                            setState(() {
                              if (isSelected) {
                                selectedPeriods.remove(period);
                              } else {
                                selectedPeriods.add(period);
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accentColor
                                : isAvailable
                                    ? accentColor.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : isAvailable
                                      ? accentColor.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                className.contains('Lab')
                                    ? Icons.laptop_mac
                                    : Icons.school,
                                color: isSelected
                                    ? Colors.white
                                    : isAvailable
                                        ? accentColor
                                        : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    period,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : isAvailable
                                              ? accentColor
                                              : Colors.red,
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    className,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.9)
                                          : textColor,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                              if (!isAvailable) ...[
                                SizedBox(width: screenWidth * 0.02),
                                Icon(
                                  Icons.warning,
                                  color: Colors.red,
                                  size: screenWidth * 0.035,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _declineRequest(request),
                    icon: Icon(Icons.close, size: screenWidth * 0.035),
                    label: const Text('Decline'),
                    style: TextButton.styleFrom(
                      foregroundColor: textColor,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  ElevatedButton.icon(
                    onPressed: selectedPeriods.isEmpty
                        ? null
                        : () => _acceptRequest(request,
                            selectedPeriods: selectedPeriods),
                    icon: Icon(Icons.check, size: screenWidth * 0.035),
                    label: const Text('Accept Selected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  void _acceptRequest(CoverageRequest request,
      {required List<String> selectedPeriods}) {
    setState(() {
      // Remove from incoming requests
      incomingRequests.remove(request);

      // Create a new request with only selected periods
      Map<String, String> acceptedClasses = {};
      for (var period in selectedPeriods) {
        if (request.periodClassMap.containsKey(period)) {
          acceptedClasses[period] = request.periodClassMap[period]!;
        }
      }

      // Create accepted request
      CoverageRequest acceptedRequest = CoverageRequest(
        requestingFaculty: request.requestingFaculty,
        date: request.date,
        periodClassMap: acceptedClasses,
        availablePeriods: request.availablePeriods,
        isLab: request.isLab,
        requestTime: DateTime.now(),
      );

      // Add to accepted requests
      requestStatus[acceptedRequest] = 'accepted';

      // Only add to declined requests if explicitly declined
      // Removing the code that adds unselected periods to declined requests

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accepted ${selectedPeriods.length} periods'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _declineRequest(CoverageRequest request) {
    setState(() {
      // Remove from incoming requests
      incomingRequests.remove(request);

      // Add to declined requests
      declinedRequests.add(request);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request declined'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  // Helper function to show relative time
  String timeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _openUnavailabilityPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnavailabilityPage(
          facultyName: widget.facultyName,
          department: widget.department,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        unavailablePeriods = result;
        // Add a sample notification (this would normally come from the backend)
        coverageNotifications.insert(
            0,
            CoverageNotification(
              date: DateTime.now(),
              className: classSchedule[result.entries.first.key]
                      ?[result.entries.first.value.first] ??
                  '',
              period: timeSlots[result.entries.first.value.first],
              acceptedFaculty: 'Pending Assignment',
              acceptedTime: DateTime.now(),
            ));
      });
    }
  }

  void _showNotificationHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: screenHeight * 0.8,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor.withOpacity(0.8), accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.white),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Notification History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Tabs and Content
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'Accepted'),
                        Tab(text: 'Declined'),
                      ],
                      labelColor: accentColor,
                      unselectedLabelColor: textColor,
                      indicatorColor: accentColor,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Accepted Tab
                          ListView(
                            padding: EdgeInsets.all(15),
                            children: requestStatus.entries
                                .where((e) => e.value == 'accepted')
                                .map((e) => _buildHistoryCard(e.key, e.value))
                                .toList(),
                          ),
                          // Declined Tab
                          ListView(
                            padding: EdgeInsets.all(15),
                            children: declinedRequests
                                .map((r) => _buildHistoryCard(r, 'declined'))
                                .toList(),
                          ),
                        ],
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

  Widget _buildHistoryCard(CoverageRequest request, String status) {
    Color statusColor = status == 'accepted'
        ? Colors.green
        : status == 'declined'
            ? Colors.red
            : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.requestingFaculty,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenWidth * 0.01),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${request.date.day}/${request.date.month}/${request.date.year}',
            style: TextStyle(
              color: textColor,
              fontSize: screenWidth * 0.03,
            ),
          ),
          SizedBox(height: 8),
          ...request.periodClassMap.entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '${entry.key} - ${entry.value}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.refresh_outlined,
                    size: screenWidth * 0.04, color: accentColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: cardColor,
                      title: Text(
                        'Move to Coverage Requests?',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'This will move the request back to pending coverage requests for review.',
                        style: TextStyle(color: textColor),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateRequest(request, {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                          ),
                          child: Text(
                            'Move',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Move to Coverage Requests',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateRequest(CoverageRequest request, Map<String, bool> selections) {
    // Create a new request with all original classes combined
    Map<String, String> allClasses = {};

    // Add classes from accepted status if any
    requestStatus.entries
        .where((e) =>
            e.key.requestingFaculty == request.requestingFaculty &&
            e.key.date == request.date)
        .forEach((e) => allClasses.addAll(e.key.periodClassMap));

    // Add classes from declined status
    declinedRequests
        .where((r) =>
            r.requestingFaculty == request.requestingFaculty &&
            r.date == request.date)
        .forEach((r) => allClasses.addAll(r.periodClassMap));

    // Create new request with all classes
    final newRequest = CoverageRequest(
      requestingFaculty: request.requestingFaculty,
      date: request.date,
      periodClassMap: allClasses, // All original classes combined
      availablePeriods: request.availablePeriods,
      isLab: request.isLab,
      requestTime: DateTime.now(),
    );

    setState(() {
      // Remove from both lists
      requestStatus.removeWhere((key, _) =>
          key.requestingFaculty == request.requestingFaculty &&
          key.date == request.date);
      declinedRequests.removeWhere((r) =>
          r.requestingFaculty == request.requestingFaculty &&
          r.date == request.date);

      // Add combined request back to incoming
      incomingRequests.add(newRequest);
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request moved back with ${allClasses.length} classes'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    final today = DateTime.now();
    final dayName = _getDayName(today.weekday);
    final todaySchedule = classSchedule[dayName] ?? {};

    // Combine consecutive periods of same class
    List<Map<String, dynamic>> combinedSchedule = [];
    MapEntry<int, String>? lastEntry;

    for (var entry in todaySchedule.entries) {
      if (lastEntry != null &&
          lastEntry!.value == entry.value &&
          lastEntry!.key + 1 == entry.key) {
        // Update the last entry's end period
        combinedSchedule.last['endPeriod'] = entry.key;
      } else {
        // Add new entry
        combinedSchedule.add({
          'startPeriod': entry.key,
          'endPeriod': entry.key,
          'className': entry.value,
        });
      }
      lastEntry = entry;
    }

    if (todaySchedule.isEmpty) {
      return Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy,
                color: accentColor.withOpacity(0.7), size: screenWidth * 0.08),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'No classes scheduled for today',
              style: TextStyle(
                color: textColor,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showWeeklySchedule(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header with class count
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.01,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: accentColor, size: screenWidth * 0.05),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      dayName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${todaySchedule.length} Classes',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Add box container for timeline
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                left: BorderSide(color: Colors.grey.withOpacity(0.2)),
                right: BorderSide(color: Colors.grey.withOpacity(0.2)),
                bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            child: Column(
              children: combinedSchedule.map((schedule) {
                final startPeriod = schedule['startPeriod'] as int;
                final endPeriod = schedule['endPeriod'] as int;
                final className = schedule['className'] as String;
                final isLab = className.contains('Lab');
                final isCurrentPeriod = _isCurrentPeriod(startPeriod);

                return Container(
                  width: double.infinity,
                  height: screenHeight * 0.035,
                  margin: EdgeInsets.only(bottom: screenHeight * 0.005),
                  child: Row(
                    children: [
                      // Timeline dot and line
                      SizedBox(
                        width: screenWidth * 0.1,
                        child: Column(
                          children: [
                            Container(
                              width: screenWidth * 0.015,
                              height: screenWidth * 0.015,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrentPeriod
                                    ? accentColor
                                    : _isPeriodCompleted(startPeriod)
                                        ? Colors.green
                                        : backgroundColor,
                                border: Border.all(
                                  color: _isPeriodCompleted(startPeriod)
                                      ? Colors.green
                                      : accentColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 2,
                                color: _isPeriodCompleted(startPeriod)
                                    ? Colors.green.withOpacity(0.7)
                                    : accentColor.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Period content
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: screenWidth * 0.25,
                                child: Text(
                                  startPeriod == endPeriod
                                      ? timeSlots[startPeriod]
                                      : '${timeSlots[startPeriod].split(' - ')[0]} - ${timeSlots[endPeriod].split(' - ')[1]}',
                                  style: TextStyle(
                                    color: isCurrentPeriod
                                        ? accentColor
                                        : textColor,
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        className.replaceAll(' (Lab)', ''),
                                        style: TextStyle(
                                          color: isCurrentPeriod
                                              ? accentColor
                                              : textColor,
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isLab)
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: screenWidth * 0.02),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02,
                                          vertical: screenHeight * 0.002,
                                        ),
                                        decoration: BoxDecoration(
                                          color: className.contains('BCA')
                                              ? Colors.blue.withOpacity(0.2)
                                              : Colors.purple.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                                className.contains('BCA')
                                                    ? Icons.laptop_mac
                                                    : Icons.science,
                                                color: className.contains('BCA')
                                                    ? Colors.blue
                                                    : Colors.purple,
                                                size: screenWidth * 0.03),
                                            SizedBox(width: screenWidth * 0.01),
                                            Text(
                                              'LAB',
                                              style: TextStyle(
                                                color: className.contains('BCA')
                                                    ? Colors.blue
                                                    : Colors.purple,
                                                fontSize: screenWidth * 0.025,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Add these helper methods
  bool _isCurrentPeriod(int periodIndex) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    final periodTime = timeSlots[periodIndex].split(' - ')[0].split(':');
    final periodStart =
        int.parse(periodTime[0]) * 60 + int.parse(periodTime[1]);

    final nextPeriodTime = timeSlots[periodIndex].split(' - ')[1].split(':');
    final periodEnd =
        int.parse(nextPeriodTime[0]) * 60 + int.parse(nextPeriodTime[1]);

    return currentTime >= periodStart && currentTime <= periodEnd;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return '';
    }
  }

  bool _isPeriodCompleted(int periodIndex) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    final nextPeriodTime = timeSlots[periodIndex].split(' - ')[1].split(':');
    final periodEnd =
        int.parse(nextPeriodTime[0]) * 60 + int.parse(nextPeriodTime[1]);

    return currentTime > periodEnd;
  }

  void _showWeeklySchedule() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: screenWidth,
          height: screenHeight * 0.85,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.8), accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Weekly Schedule',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Schedule Content with Column Animation
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Column
                    TweenAnimationBuilder(
                      duration: Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(-50 * (1 - value), 0),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              width: 80,
                              color: cardColor,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      'Time',
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ...List.generate(timeSlots.length, (index) {
                                    return Container(
                                      height: 100,
                                      padding: EdgeInsets.all(8),
                                      alignment: Alignment.center,
                                      child: Text(
                                        timeSlots[index],
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Day Columns
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(6, (dayIndex) {
                            final dayName = _getDayName(dayIndex + 1);
                            final isToday = dayName == _getDayName(DateTime.now().weekday);
                            final daySchedule = classSchedule[dayName] ?? {};

                            return TweenAnimationBuilder(
                              duration: Duration(milliseconds: 500),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, double value, child) {
                                return Transform.translate(
                                  offset: Offset(100 * (1 - value), 0),
                                  child: Opacity(
                                    opacity: value,
                                    child: Container(
                                      width: 200,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: textColor.withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isToday ? accentColor : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      dayName,
                                      style: TextStyle(
                                        color: isToday ? accentColor : textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Add class cells
                                  ...List.generate(timeSlots.length, (timeIndex) {
                                    final classInfo = daySchedule[timeIndex];
                                    return classInfo != null
                                        ? _buildAnimatedClassCell(
                                            classInfo,
                                            isCurrentPeriod: _isCurrentPeriod(timeIndex) && isToday,
                                          )
                                        : Container(height: 100);
                                  }),
                                ],
                              ),
                            );
                          }),
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

  Widget _buildAnimatedClassCell(String classInfo, {bool isCurrentPeriod = false}) {
    final isLab = classInfo.contains('Lab');
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrentPeriod
                  ? accentColor.withOpacity(0.2)
                  : isLab
                      ? (classInfo.contains('BCA')
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.1))
                      : accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrentPeriod ? accentColor : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLab)
                  Icon(
                    classInfo.contains('BCA') ? Icons.laptop_mac : Icons.science,
                    color: classInfo.contains('BCA') ? Colors.blue : Colors.purple,
                    size: 16,
                  ),
                Text(
                  classInfo.replaceAll(' (Lab)', ''),
                  style: TextStyle(
                    color: isCurrentPeriod ? accentColor : textColor,
                    fontSize: 14,
                    fontWeight: isCurrentPeriod ? FontWeight.bold : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
