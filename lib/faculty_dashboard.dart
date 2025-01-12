import 'package:flutter/material.dart';
import 'pages/unavailability_page.dart';
import 'faculty/settings_page.dart';

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

  // Define colors
  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  final List<String> timeSlots = [
    '8:50 - 9:40',
    '9:45 - 10:35',
    '10:40 - 11:30',
    '11:35 - 12:25',
    '1:05 - 1:55',
    '2:00 - 2:50',
    '2:55 - 3:45',
    '3:50 - 4:40',
  ];

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

  Map<String, Map<int, String>> classSchedule = {
    'Monday': {
      0: 'I BSc B (Lab)',
      1: 'I BSc B (Lab)',
      2: 'I BSc B (Lab)',
      3: 'I BSc B (Lab)',
      5: 'III BCA B',
      6: 'I BSc C',
      7: 'II BCA A',
    },
    'Tuesday': {
      1: 'II BCA A',
      2: 'III BSc B',
      3: 'I BCA C',
      5: 'II BSc A (Lab)',
      6: 'II BSc A (Lab)',
    },
    'Wednesday': {
      0: 'III BCA A',
      1: 'I BSc B',
      3: 'II BCA B',
      4: 'III BSc A',
      6: 'I BCA A (Lab)',
      7: 'I BCA A (Lab)',
    },
    'Thursday': {
      1: 'II BSc B',
      2: 'III BCA C',
      4: 'I BSc A (Lab)',
      5: 'I BSc A (Lab)',
      6: 'II BCA C',
    },
    'Friday': {
      0: 'III BSc C',
      1: 'II BCA B',
      2: 'I BSc A',
      4: 'III BCA B (Lab)',
      5: 'III BCA B (Lab)',
      7: 'II BSc C',
    },
  };

  Map<CoverageRequest, String> requestStatus =
      {}; // Stores request -> status mapping

  List<CoverageRequest> declinedRequests = []; // Store declined requests

  // Add this sample faculty profile data
  final Map<String, dynamic> facultyProfile = {
    'name': 'Dr. Rajesh Kumar',
    'designation': 'Associate Professor',
    'department': 'Computer Science',
    'email': 'rajesh.kumar@college.edu',
    'phone': '+91 98765 43210',
    'qualification': 'Ph.D in Computer Science',
    'dob': '15-05-1980',
    'experience': '12 years',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined, color: textColor),
                if (requestStatus.isNotEmpty)
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
                        requestStatus.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FacultySettingsPage(
                    facultyName: widget.facultyName,
                    department: widget.department,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with click functionality
            InkWell(
              onTap: () => _showFacultyDetails(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: accentColor,
                          child: Text(
                            widget.facultyName.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.facultyName,
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 24,
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
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: accentColor,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTodaySchedule(), // Add today's schedule preview
                  ],
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Main Content - Compact Unavailability Card
                  Container(
                    height: 100, // Fixed compact height
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
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mark Unavailability',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'View and update your schedule',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: accentColor,
                                size: 20,
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
                  ] else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: accentColor.withOpacity(0.2)),
                      ),
                      child: const Center(
                        child: Text(
                          'No coverage notifications yet',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

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
                  fontSize: 12,
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

    void _showConflictWarning(String period, Function() onConfirm) {
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
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor.withOpacity(0.8), accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      request.requestingFaculty[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.requestingFaculty,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeAgo(request.requestTime),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${request.date.day}/${request.date.month}/${request.date.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Period chips
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select periods to cover:',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: request.periodClassMap.entries.map((entry) {
                      final period = entry.key;
                      final className = entry.value;
                      final isAvailable =
                          request.availablePeriods.contains(period);
                      final isSelected = selectedPeriods.contains(period);

                      return InkWell(
                        onTap: () {
                          if (!isAvailable) {
                            _showConflictWarning(period, () {
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    className,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.9)
                                          : textColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              if (!isAvailable) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.warning,
                                  color: Colors.red,
                                  size: 14,
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
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: TextButton.styleFrom(
                      foregroundColor: textColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: selectedPeriods.isEmpty
                        ? null
                        : () => _acceptRequest(request,
                            selectedPeriods: selectedPeriods),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept Selected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
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

      // If there are unselected periods, add them to declined
      Map<String, String> declinedClasses = Map.from(request.periodClassMap)
        ..removeWhere((key, _) => selectedPeriods.contains(key));

      if (declinedClasses.isNotEmpty) {
        CoverageRequest declinedRequest = CoverageRequest(
          requestingFaculty: request.requestingFaculty,
          date: request.date,
          periodClassMap: declinedClasses,
          availablePeriods: request.availablePeriods,
          isLab: request.isLab,
          requestTime: DateTime.now(),
        );
        declinedRequests.add(declinedRequest);
      }

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
        height: MediaQuery.of(context).size.height * 0.8,
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
                  SizedBox(width: 12),
                  Text(
                    'Notification History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
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
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
          ...request.periodClassMap.entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '${entry.key} - ${entry.value}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                  ),
                ),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon:
                    Icon(Icons.refresh_outlined, size: 20, color: accentColor),
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

    if (todaySchedule.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: const Text(
          'No classes scheduled for today',
          style: TextStyle(color: textColor),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, color: accentColor, size: 16),
            const SizedBox(width: 8),
            Text(
              "Today's Schedule ($dayName)",
              style: const TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todaySchedule.length,
            itemBuilder: (context, index) {
              final entry = todaySchedule.entries.elementAt(index);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: index != todaySchedule.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: accentColor.withOpacity(0.1),
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        timeSlots[entry.key],
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: entry.value.contains('Lab')
                            ? Colors.purple.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.value.contains('Lab') ? 'Lab' : 'Theory',
                        style: TextStyle(
                          color: entry.value.contains('Lab')
                              ? Colors.purple
                              : Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
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
      default:
        return '';
    }
  }

  void _showFacultyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: 'Details'),
                        Tab(text: 'Weekly Schedule'),
                      ],
                      labelColor: accentColor,
                      unselectedLabelColor: textColor,
                      indicatorColor: accentColor,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildFacultyDetailsTab(),
                          _buildWeeklyScheduleTab(),
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

  Widget _buildFacultyDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 16),
        _buildDetailCard(
          title: 'Contact Information',
          icon: Icons.contact_mail,
          children: [
            _buildDetailRow('Email', facultyProfile['email']),
            _buildDetailRow('Phone', facultyProfile['phone']),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          title: 'Academic Profile',
          icon: Icons.school,
          children: [
            _buildDetailRow('Qualification', facultyProfile['qualification']),
            _buildDetailRow('Experience', facultyProfile['experience']),
            _buildDetailRow('Date of Birth', facultyProfile['dob']),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          title: "Today's Schedule",
          icon: Icons.schedule,
          children: [
            _buildTodaySchedule(),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyScheduleTab() {
    return DefaultTabController(
      length: 5, // For Monday to Friday
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                .map((day) {
              return Tab(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    day,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            }).toList(),
            labelColor: accentColor,
            unselectedLabelColor: textColor.withOpacity(0.5),
            indicatorColor: accentColor,
          ),
          Expanded(
            child: TabBarView(
              children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                  .map((day) {
                final daySchedule = classSchedule[day] ?? {};
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: daySchedule.length,
                  itemBuilder: (context, index) {
                    final period = daySchedule.entries.elementAt(index);
                    final isLab = period.value.contains('Lab');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (isLab)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'LAB',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 80,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                timeSlots[period.key],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              period.value.replaceAll(' (Lab)', ''),
                              style: const TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  isLab ? Icons.computer : Icons.class_,
                                  color: textColor.withOpacity(0.7),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isLab ? 'Laboratory' : 'Theory Class',
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.8),
            accentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            facultyProfile['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            facultyProfile['designation'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            facultyProfile['department'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: accentColor, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
