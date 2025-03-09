import 'package:flutter/material.dart';
import '../utils/responsive_util.dart' show ResponsiveUtil;
import 'dart:ui';

class UnavailabilityPage extends StatefulWidget {
  final String facultyName;
  final String department;

  const UnavailabilityPage({
    super.key,
    required this.facultyName,
    required this.department,
  });

  @override
  State<UnavailabilityPage> createState() => _UnavailabilityPageState();
}

class _UnavailabilityPageState extends State<UnavailabilityPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Updated to match theme colors
  static const backgroundColor =
      Color.fromRGBO(24, 29, 32, 1); // Match dashboard background
  static const cardColor =
      Color.fromRGBO(34, 39, 42, 1); // Match dashboard card color
  static const accentColor =
      Color.fromRGBO(153, 55, 30, 1); // Match dashboard accent
  static const textColor =
      Color.fromRGBO(159, 160, 162, 1); // Match dashboard text
  static const neutralGray =
      Color.fromRGBO(34, 39, 42, 1); // Match dashboard neutral

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

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  Map<String, List<int>> unavailablePeriods = {};
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
      0: 'III BSc C',
      1: 'II BCA C',
      4: 'II BCA A (Lab)',
      5: 'II BCA A (Lab)',
      6: 'II BCA A (Lab)',
      7: 'II BCA A (Lab)',
    },
    'Wednesday': {
      0: 'III BSc B (Lab)',
      1: 'III BSc B (Lab)',
      2: 'III BSc B (Lab)',
      3: 'III BSc B (Lab)',
      6: 'II BSc A',
      7: 'II BCA A',
    },
    'Thursday': {
      0: 'II BSc B',
      1: 'I BCA C',
      4: 'I BSc A (Lab)',
      5: 'I BSc A (Lab)',
      6: 'I BSc A (Lab)',
      7: 'I BSc A (Lab)',
    },
    'Friday': {
      0: 'II BCA C (Lab)',
      1: 'II BCA C (Lab)',
      2: 'II BCA C (Lab)',
      3: 'II BCA C (Lab)',
      5: 'I BCA A',
      6: 'III BSc A',
    },
    'Saturday': {
      0: 'III BCA C (Lab)',
      1: 'III BCA C (Lab)',
      2: 'III BCA C (Lab)',
    },
  };

  DateTime selectedDate = DateTime.now();
  String? selectedClass;
  String? selectedDay;
  int? selectedPeriod;
  bool showRequestForm = false;
  Set<String> selectedPeriods = {};
  bool showHowItWorks = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fetchScheduleFromDatabase();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildHowItWorksButton(),
                        SizedBox(height: 16),
                        _buildTimeTable(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showHowItWorks) _buildHowItWorksPopup(),
          if (showRequestForm) _buildModernRequestForm(),
        ],
      ),
      bottomNavigationBar:
          selectedPeriods.isNotEmpty ? _buildBottomButtons() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: backgroundColor,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor,
              cardColor.withOpacity(0.8),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            'Schedule & Unavailability',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          background: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(
                    color: accentColor.withOpacity(0.05),
                    spacing: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            ...days.map((day) => _buildTimeRow(day)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.2),
            accentColor.withOpacity(0.2),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          _buildHeaderCell('Time/Day', isFirst: true),
          ...timeSlots.map((slot) => _buildHeaderCell(slot)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {bool isFirst = false}) {
    return Container(
      width: isFirst ? 100 : 120,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeRow(String day) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: neutralGray.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildDayCell(day),
          ...List.generate(
            timeSlots.length,
            (index) => _buildPeriodCell(day, index),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(String day) {
    return InkWell(
      onTap: () {
        setState(() {
          // Get all periods for this day
          final daySchedule = classSchedule[day] ?? {};

          // Check if all periods for this day are already selected
          bool allSelected = daySchedule.entries.every(
              (entry) => selectedPeriods.contains("${day}_${entry.key}"));

          if (allSelected) {
            // If all are selected, deselect all periods for this day
            selectedPeriods
                .removeWhere((period) => period.startsWith("${day}_"));
          } else {
            // If not all are selected, select all periods for this day
            daySchedule.forEach((periodIndex, className) {
              selectedPeriods.add("${day}_$periodIndex");
            });
          }
        });
      },
      child: Container(
        width: 100,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: neutralGray.withOpacity(0.3),
          border: Border(
            right: BorderSide(
              color: neutralGray.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Text(
          day,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPeriodCell(String day, int period) {
    final className = classSchedule[day]?[period];
    final isLab = className != null && className.contains('(Lab)');

    // Check if the current period is part of a merged lab period
    bool isMergedLab = false;
    if (isLab && period >= 0 && period <= 3) {
      // Check if the next three periods are also lab periods
      isMergedLab =
          classSchedule[day]?[period + 1]?.contains('(Lab)') == true &&
              classSchedule[day]?[period + 2]?.contains('(Lab)') == true &&
              classSchedule[day]?[period + 3]?.contains('(Lab)') == true;
    }

    // If there's no class or it's an empty slot
    if (className == null || className.isEmpty) {
      return Container(
        width: 120,
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.5), // Slightly darker for empty cells
          border: Border(
            right: BorderSide(
              color: neutralGray.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            'Empty Slot',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    // Regular class display
    return GestureDetector(
      onTap: () {
        if (selectedPeriods.isNotEmpty) {
          String firstDay = selectedPeriods.first.split('_')[0];
          if (day != firstDay) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please select periods from $firstDay only',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.fixed,
                dismissDirection: DismissDirection.up,
              ),
            );
            return;
          }
        }
        setState(() {
          final periodKey = "${day}_$period";
          if (selectedPeriods.contains(periodKey)) {
            selectedPeriods.remove(periodKey);
          } else {
            selectedPeriods.add(periodKey);
          }
        });
      },
      child: Container(
        width: 120,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedPeriods.contains("${day}_$period")
              ? accentColor.withOpacity(0.2)
              : null,
          border: Border(
            right: BorderSide(
              color: neutralGray.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLab ? Icons.computer : Icons.school,
              color: selectedPeriods.contains("${day}_$period")
                  ? accentColor
                  : textColor.withOpacity(0.7),
              size: 18,
            ),
            SizedBox(height: 4),
            Text(
              className,
              style: TextStyle(
                color: selectedPeriods.contains("${day}_$period")
                    ? accentColor
                    : textColor.withOpacity(0.9),
                fontSize: 12,
                fontWeight: selectedPeriods.contains("${day}_$period")
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernRequestForm() {
    if (!showRequestForm) return const SizedBox.shrink();

    List<String> selectedDetails = [];
    for (String periodKey in selectedPeriods) {
      final parts = periodKey.split('_');
      final day = parts[0];
      final period = int.parse(parts[1]);
      final className = classSchedule[day]?[period] ?? '';
      final timeSlot = timeSlots[period];
      selectedDetails.add('$className ($timeSlot)');
    }

    return Stack(
      children: [
        // Full-screen overlay to prevent interaction with the background
        GestureDetector(
          onTap: () {
            // Close the popup when clicking outside
            setState(() {
              showRequestForm = false;
              selectedPeriods.clear();
            });
          },
          child: Container(
            color: Colors.black54, // Semi-transparent background
          ),
        ),
        // Blurred background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirm Unavailability',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _selectDate(context),
                              icon: Icon(
                                Icons.calendar_today,
                                color: accentColor,
                                size: 20,
                              ),
                              label: Text(
                                'Change',
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(color: neutralGray),
                        Text(
                          'Total Hours: ${_calculateTotalHours()} hrs',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: selectedDetails
                            .map((detail) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.schedule,
                                          color: accentColor, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        detail,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showRequestForm = false;
                            selectedPeriods.clear();
                          });
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Submit Request',
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
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Get the first selected period's day
    String selectedDay = '';
    if (selectedPeriods.isNotEmpty) {
      selectedDay = selectedPeriods.first.split('_')[0];
    }

    // Find the next occurrence of the selected day
    DateTime firstAllowedDate = DateTime.now();
    while (firstAllowedDate.weekday != _getDayNumber(selectedDay)) {
      firstAllowedDate = firstAllowedDate.add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstAllowedDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime.now().add(const Duration(days: 30)),
      selectableDayPredicate: (DateTime date) {
        // Only allow the same weekday as the selected periods
        return date.weekday == _getDayNumber(selectedDay);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              surface: cardColor,
            ),
            dialogBackgroundColor: backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Helper method to convert day name to number
  int _getDayNumber(String day) {
    switch (day) {
      case 'Monday':
        return DateTime.monday;
      case 'Tuesday':
        return DateTime.tuesday;
      case 'Wednesday':
        return DateTime.wednesday;
      case 'Thursday':
        return DateTime.thursday;
      case 'Friday':
        return DateTime.friday;
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  String _calculateTotalHours() {
    int totalPeriods = selectedPeriods.length;
    // Each period is 50 minutes = 0.833 hours
    double totalHours = totalPeriods * 0.833;
    return totalHours.toStringAsFixed(1);
  }

  void _submitRequest() {
    // TODO: Implement the API call to submit the request
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request submitted successfully'),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    setState(() {
      showRequestForm = false;
      selectedPeriods.clear();
    });
  }

  Future<void> _fetchScheduleFromDatabase() async {
    // TODO: Implement database fetch
    // For now, using the hardcoded classSchedule
    setState(() {
      // classSchedule is already defined with default values
    });
  }

  Widget _buildHowItWorksButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => showHowItWorks = true),
        icon: Icon(Icons.help_outline, color: Colors.white),
        label: Text(
          'How it works?',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksPopup() {
    return Container(
      color: Colors.black54,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How it works?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.check, color: const Color(0xFF4CAF50)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select the periods you want to mark as unavailable.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Click on "New Request" to submit your unavailability.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showHowItWorks = false;
                    });
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      color: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedPeriods.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Selection cleared',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.grey[800],
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.fixed,
                  dismissDirection: DismissDirection.up,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cardColor,
              minimumSize: Size(double.infinity, 45),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Clear Selection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _validateAndShowRequestForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              minimumSize: Size(double.infinity, 45),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'New Request (${selectedPeriods.length} periods)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add validation to ensure all selected periods are from the same day
  void _validateAndShowRequestForm() {
    if (selectedPeriods.isEmpty) return;

    // Get the day of the first selected period
    String firstDay = selectedPeriods.first.split('_')[0];

    // Check if all selected periods are from the same day
    bool allSameDay =
        selectedPeriods.every((period) => period.split('_')[0] == firstDay);

    if (!allSameDay) {
      // Show error message if periods from different days are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select periods from the same day only'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // Clear selection
      setState(() {
        selectedPeriods.clear();
      });
      return;
    }

    // If validation passes, show the request form
    setState(() {
      showRequestForm = true;
    });
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  GridPainter({required this.color, this.spacing = 20});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
