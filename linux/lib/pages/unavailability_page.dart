import 'package:flutter/material.dart';
import '../utils/responsive_util.dart';

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

  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);
  static const headerGradient = LinearGradient(
    colors: [
      Color(0xFF993720),
      Color(0xFFB54B30),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
    ResponsiveUtil().init(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Text(
          'Schedule & Unavailability',
          style: TextStyle(
            color: textColor,
            fontSize: ResponsiveUtil.hp(2.2),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveChanges,
            icon: Icon(
              Icons.save,
              color: accentColor,
              size: ResponsiveUtil.hp(2.5),
            ),
            label: Text(
              'Save',
              style: TextStyle(
                color: accentColor,
                fontSize: ResponsiveUtil.hp(2),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(ResponsiveUtil.wp(4)),
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildHeaderCell(
                                'Day/Time',
                                width: ResponsiveUtil.wp(25),
                              ),
                              ...List.generate(
                                timeSlots.length,
                                (index) => _buildHeaderCell(
                                  'Period $index\n${timeSlots[index]}',
                                  width: ResponsiveUtil.wp(30),
                                  period: index,
                                ),
                              ),
                            ],
                          ),
                          ...days.map((day) => _buildTimeTableRow(day)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (showRequestForm) _buildRequestForm(),
            ],
          );
        },
      ),
      floatingActionButton: selectedPeriods.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  showRequestForm = true;
                });
              },
              backgroundColor: accentColor,
              icon: Icon(
                Icons.arrow_forward,
                size: ResponsiveUtil.hp(2.5),
              ),
              label: Text(
                'Continue (${_calculateTotalHours()} hrs)',
                style: TextStyle(fontSize: ResponsiveUtil.hp(1.8)),
              ),
            )
          : null,
    );
  }

  Widget _buildHeaderCell(String text, {double width = 120.0, int? period}) {
    return GestureDetector(
      onTap: () {
        if (period == null) return;
        setState(() {
          bool anySelected =
              days.any((day) => selectedPeriods.contains("${day}_$period"));

          if (anySelected) {
            // Deselect all classes in this period
            selectedPeriods.removeWhere((key) => key.endsWith("_$period"));
          } else {
            // Select all classes in this period
            for (String day in days) {
              if (classSchedule[day]?[period] != null) {
                selectedPeriods.add("${day}_$period");
              }
            }
          }
        });
      },
      child: Container(
        width: width,
        height: 65.0,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: headerGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTableRow(String day) {
    // Check if all available periods for this day are selected
    final availablePeriods =
        classSchedule[day]?.entries.map((e) => "${day}_${e.key}").toSet() ?? {};
    final allPeriodsSelected = availablePeriods.isNotEmpty &&
        availablePeriods.every((period) => selectedPeriods.contains(period));

    return Row(
      children: [
        // Day cell
        GestureDetector(
          onTap: () {
            setState(() {
              if (allPeriodsSelected) {
                // Remove all periods of this day
                selectedPeriods.removeAll(availablePeriods);
              } else {
                // Add all available periods of this day
                selectedPeriods.addAll(availablePeriods);
              }
            });
          },
          child: Container(
            width: 100.0,
            height: 65.0,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: allPeriodsSelected
                    ? [accentColor.withOpacity(0.6), accentColor]
                    : [Color(0xFF993720), Color(0xFF7A2D1D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: allPeriodsSelected
                      ? accentColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (allPeriodsSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        ...List.generate(
          8,
          (index) => _buildPeriodCell(day, index),
        ),
      ],
    );
  }

  Widget _buildPeriodCell(String day, int period) {
    final className = classSchedule[day]?[period];
    final isSelected = selectedPeriods.contains("${day}_$period");

    if (className == null) {
      return Container(
        width: ResponsiveUtil.wp(30),
        height: ResponsiveUtil.hp(8),
        margin: EdgeInsets.all(ResponsiveUtil.wp(0.75)),
      );
    }

    // Check if this is part of a lab session
    bool isLab = className.contains('(Lab)');
    bool isLabStart = isLab && (period == 0 || period == 4);
    bool shouldSkip = isLab && !isLabStart;

    // Skip rendering for non-starting lab periods
    if (shouldSkip) {
      return SizedBox.shrink();
    }

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isLab) {
                  // For labs, select/deselect all 4 periods together
                  final startPeriod = period;
                  for (int i = 0; i < 4; i++) {
                    final periodKey = "${day}_${startPeriod + i}";
                    if (isSelected) {
                      selectedPeriods.remove(periodKey);
                    } else {
                      selectedPeriods.add(periodKey);
                    }
                  }
                } else {
                  final periodKey = "${day}_$period";
                  if (isSelected) {
                    selectedPeriods.remove(periodKey);
                  } else {
                    selectedPeriods.add(periodKey);
                  }
                }
              });
            },
            child: Container(
              width: isLab
                  ? ResponsiveUtil.wp(122)
                  : ResponsiveUtil.wp(30), // 4x width for labs
              height: ResponsiveUtil.hp(8),
              margin: EdgeInsets.all(ResponsiveUtil.wp(0.75)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [accentColor.withOpacity(0.8), accentColor]
                      : [cardColor, Color(0xFF2C2520)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ResponsiveUtil.wp(3)),
                border: Border.all(
                  color: isSelected ? accentColor : Colors.transparent,
                  width: ResponsiveUtil.wp(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? accentColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      className,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtil.hp(1.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtil.hp(0.5)),
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : isLab
                              ? (className.contains('BCA')
                                  ? Icons.laptop_mac
                                  : Icons.science)
                              : Icons.school_rounded,
                      size: ResponsiveUtil.hp(2),
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveChanges() {
    // TODO: Implement saving logic
    Navigator.pop(context, unavailablePeriods);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully'),
        backgroundColor: accentColor,
      ),
    );
  }

  void _submitRequest() {
    // TODO: Implement the API call to submit the request
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request submitted successfully'),
        backgroundColor: accentColor,
      ),
    );
    setState(() {
      showRequestForm = false;
      selectedPeriods.clear();
    });
  }

  Widget _buildRequestForm() {
    if (!showRequestForm) return const SizedBox.shrink();

    // Get all selected classes and their times
    List<String> selectedDetails = [];
    for (String periodKey in selectedPeriods) {
      final parts = periodKey.split('_');
      final day = parts[0];
      final period = int.parse(parts[1]);
      final className = classSchedule[day]?[period] ?? '';
      final timeSlot = timeSlots[period];
      selectedDetails.add('$className ($timeSlot)');
    }

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cardColor, Color(0xFF2C2520)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: TextStyle(
                  color: textColor,
                  fontSize: ResponsiveUtil.hp(1.8),
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context),
                style: TextButton.styleFrom(
                  foregroundColor: accentColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: ResponsiveUtil.hp(2)),
                    SizedBox(width: 8),
                    Text(
                      'Change Date',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.hp(1.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Total Hours: ${_calculateTotalHours()} hrs',
                style: TextStyle(
                  color: accentColor,
                  fontSize: ResponsiveUtil.hp(2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedDetails
                      .map((detail) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              detail,
                              style: TextStyle(
                                color: textColor,
                                fontSize: ResponsiveUtil.hp(1.6),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showRequestForm = false;
                      });
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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

  String _calculateTotalHours() {
    int totalPeriods = selectedPeriods.length;
    // Each period is 50 minutes = 0.833 hours
    double totalHours = totalPeriods * 0.833;
    return totalHours.toStringAsFixed(1);
  }

  Future<void> _fetchScheduleFromDatabase() async {
    // TODO: Implement database fetch
    // For now, using the hardcoded classSchedule
    setState(() {
      // classSchedule is already defined with default values
    });
  }
}

class StripePainter extends CustomPainter {
  final Color color;

  StripePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (double i = -size.width; i < size.width; i += 10) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
