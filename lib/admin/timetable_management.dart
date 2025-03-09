import 'package:flutter/material.dart';
import '../services/timetable_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class TimetableManagement extends StatefulWidget {
  final String course;
  final String year;
  final String section;

  const TimetableManagement({
    super.key,
    required this.course,
    required this.year,
    required this.section,
  });

  @override
  State<TimetableManagement> createState() => _TimetableManagementState();
}

class LabSession {
  final List<String> subjects;
  final List<String> facultyNames;
  final List<int> periods;

  LabSession({
    required this.subjects,
    required this.facultyNames,
    required this.periods,
  });
}

class _TimetableManagementState extends State<TimetableManagement>
    with SingleTickerProviderStateMixin {
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  final Map<String, Map<int, dynamic>> timetableData = {};
  final Map<String, List<LabSession>> labSessions = {};
  bool isAddingLab = false;
  String? selectedDay;
  late AnimationController _controller;
  late Animation<double> _animation;
  final Map<int, String> timeSlots = {
    0: '8:50 - 9:40',
    1: '9:45 - 10:35',
    2: '10:40 - 11:30',
    3: '11:35 - 12:25',
    4: '1:05 - 1:55',
    5: '2:00 - 2:50',
    6: '2:55 - 3:45',
    7: '3:50 - 4:40',
  };
  bool hasUnsavedChanges = false;

  final List<int> morningLabSlots = [0, 1, 2, 3]; // 8:50 to 12:25
  final List<int> afternoonLabSlots = [4, 5, 6, 7]; // 1:50 to 4:40

  bool get hasLabSessions => widget.course == 'BCA' || widget.course == 'BSc';

  final TimetableService _timetableService = TimetableService();

  Map<String, dynamic> _lastDeletedPeriod = {};
  Timer? _undoTimer;

  // Add this map to track faculty assignments
  Map<String, Map<String, Map<int, String>>> facultySchedule = {};
  // Format: {day: {timeSlot: {periodNumber: className}}}

  // Add this validation method
  bool isFacultyAvailable(String faculty, String day, int period) {
    if (facultySchedule.containsKey(day)) {
      if (facultySchedule[day]!.containsKey(faculty)) {
        return !facultySchedule[day]![faculty]!.containsKey(period);
      }
    }
    return true;
  }

  // Modify your period assignment method
  void assignFacultyToPeriod(
      String faculty, String day, int period, String className) {
    if (isFacultyAvailable(faculty, day, period)) {
      // Initialize the nested maps if they don't exist
      facultySchedule.putIfAbsent(day, () => {});
      facultySchedule[day]!.putIfAbsent(faculty, () => {});

      // Assign the faculty
      facultySchedule[day]![faculty]![period] = className;

      // Update your existing timetable data structure here
      // ... your existing code to update timetable ...
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Faculty $faculty is already assigned to another class at this time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Modify your faculty selection widget
  Widget buildFacultySelector(String day, int period, String className) {
    final currentFaculty = timetableData[day]?[period]?['faculty_name'];
    final facultyList = FirebaseFirestore.instance
        .collection('faculty')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['name'] as String).toList());

    return Tooltip(
      message: currentFaculty != null
          ? 'Current: $currentFaculty'
          : 'No faculty assigned',
      child: StreamBuilder<List<String>>(
        stream: facultyList,
        builder: (context, snapshot) {
          return DropdownButton<String>(
            value: currentFaculty,
            items: (snapshot.data ?? []).map((faculty) {
              return DropdownMenuItem<String>(
                value: faculty,
                child: Text(faculty),
                enabled: isFacultyAvailable(faculty, day, period),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  assignFacultyToPeriod(newValue, day, period, className);
                });
              }
            },
          );
        },
      ),
    );
  }

  // Add this method to clear faculty assignment when changing
  void clearFacultyAssignment(String faculty, String day, int period) {
    if (facultySchedule.containsKey(day) &&
        facultySchedule[day]!.containsKey(faculty)) {
      facultySchedule[day]![faculty]!.remove(period);
    }
  }

  // Add this helper method to get faculty assignment info
  String? getFacultyAssignment(String faculty, String day, int period) {
    if (facultySchedule.containsKey(day) &&
        facultySchedule[day]!.containsKey(faculty) &&
        facultySchedule[day]![faculty]!.containsKey(period)) {
      return facultySchedule[day]![faculty]![period];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadTimetable();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 29, 32, 1),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.course} - ${widget.year}',
              style: const TextStyle(
                color: Color.fromRGBO(159, 160, 162, 1),
                fontSize: 20,
              ),
            ),
            Text(
              'Section ${widget.section}',
              style: const TextStyle(
                color: Color.fromRGBO(153, 55, 30, 1),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
               ) ],
              ),
            ),
          IconButton(
            onPressed: _showSaveConfirmation,
            icon: const Icon(
              Icons.save,
              color: Color.fromRGBO(153, 55, 30, 1),
            ),
            tooltip: 'Save Timetable',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Panel - Day Selection
            Container(
              height: 120,
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
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Color.fromRGBO(153, 55, 30, 1),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Select Day',
                          style: TextStyle(
                            color: Color.fromRGBO(159, 160, 162, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final isSelected = selectedDay == day;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedDay = day;
                                  _controller.forward(from: 0);
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color.fromRGBO(153, 55, 30, 1)
                                      : const Color.fromRGBO(24, 29, 32, 1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color.fromRGBO(153, 55, 30, 1)
                                        : const Color.fromRGBO(
                                            153, 55, 30, 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      day.substring(
                                          0, 3), // Show first 3 letters
                                      style: TextStyle(
                                        color: const Color.fromRGBO(
                                            159, 160, 162, 1),
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? const Color.fromRGBO(
                                                159, 160, 162, 1)
                                            : Colors.transparent,
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bottom Panel - Timetable
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
                            selectedDay != null
                                ? Icons.schedule
                                : Icons.info_outline,
                            color: const Color.fromRGBO(153, 55, 30, 1),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedDay ?? 'Select a day to view timetable',
                            style: const TextStyle(
                              color: Color.fromRGBO(159, 160, 162, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: selectedDay != null
                          ? FadeTransition(
                              opacity: _animation,
                              child: _buildTimetableGrid(),
                            )
                          : const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    color: Color.fromRGBO(153, 55, 30, 1),
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Select a day from above',
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

  Widget _buildTimetableGrid() {
    final isWeekday = selectedDay != 'Saturday';
    final periods = isWeekday ? 8 : 3;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: periods,
      itemBuilder: (context, index) {
        final periodNumber = index;
        final entry = timetableData[selectedDay]?[periodNumber];
        final isLabSession = entry is LabSession;

        if (isLabSession &&
            (entry as LabSession).periods.first != periodNumber) {
          return const SizedBox.shrink();
        }

        return Dismissible(
          key: Key('period_$selectedDay$periodNumber'),
          background: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(153, 55, 30, 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              children: [
                Icon(
                  Icons.delete,
                  color: Color.fromRGBO(153, 55, 30, 1),
                ),
                SizedBox(width: 8),
                Text(
                  'Delete Period',
                  style: TextStyle(
                    color: Color.fromRGBO(153, 55, 30, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          direction: entry != null
              ? DismissDirection.startToEnd
              : DismissDirection.none,
          confirmDismiss: (direction) async {
            if (entry != null) {
              // Store the deleted period data
              _lastDeletedPeriod = {
                'day': selectedDay,
                'period': periodNumber,
                'data': entry,
              };

              // Remove from UI immediately
              setState(() {
                if (entry is LabSession) {
                  for (final labPeriod in (entry as LabSession).periods) {
                    timetableData[selectedDay]?.remove(labPeriod);
                  }
                } else {
                  timetableData[selectedDay]?.remove(periodNumber);
                }
              });

              // Show undo snackbar
              if (mounted) {
                _undoTimer?.cancel();
                ScaffoldMessenger.of(context).clearSnackBars();

                // Create a stateful snackbar that updates its content
                final snackBar = SnackBar(
                  duration: const Duration(seconds: 3),
                  backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
                  content: TweenAnimationBuilder<Duration>(
                    duration: const Duration(seconds: 3),
                    tween: Tween(
                        begin: const Duration(seconds: 3), end: Duration.zero),
                    onEnd: () {
                      // When timer ends, confirm delete
                      _confirmDelete();
                    },
                    builder:
                        (BuildContext context, Duration value, Widget? child) {
                      return Row(
                        children: [
                          const Icon(Icons.delete_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Period ${periodNumber + 1} deleted',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          if (value.inSeconds > 0) ...[
                            Text(
                              'UNDO ${value.inSeconds}s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  action: SnackBarAction(
                    label: 'UNDO',
                    textColor: Colors.white,
                    onPressed: () {
                      _undoTimer?.cancel();
                      _restorePeriodInDB(_lastDeletedPeriod);
                    },
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }

              return true;
            }
            return false;
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: const Color.fromRGBO(24, 29, 32, 1),
            child: ListTile(
              onTap: () => _showAddPeriodDialog(periodNumber),
              leading: SizedBox(
                width: 80,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: const Color.fromRGBO(153, 55, 30, 1),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      periodNumber.toString(),
                      style: const TextStyle(
                        color: Color.fromRGBO(159, 160, 162, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLabSession
                        ? '${(entry as LabSession).subjects.join(", ")} (Lab)\nFaculty: ${entry.facultyNames.join(", ")}'
                        : entry is Map
                            ? '${entry['subject']}\nFaculty: ${entry['faculty_name']}'
                            : entry?.toString() ?? 'No subject assigned',
                    style: const TextStyle(
                      color: Color.fromRGBO(159, 160, 162, 1),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timeSlots[periodNumber] ?? '',
                    style: const TextStyle(
                      color: Color.fromRGBO(153, 55, 30, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              subtitle: entry != null
                  ? const Text(
                      'Tap to edit',
                      style: TextStyle(
                        color: Color.fromRGBO(159, 160, 162, 0.5),
                        fontSize: 12,
                      ),
                    )
                  : const Text(
                      'Tap to add subject',
                      style: TextStyle(
                        color: Color.fromRGBO(159, 160, 162, 0.5),
                        fontSize: 12,
                      ),
                    ),
              trailing: Icon(
                entry != null ? Icons.edit : Icons.add,
                color: const Color.fromRGBO(153, 55, 30, 1),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddPeriodDialog(int periodNumber) {
    final entry = timetableData[selectedDay]?[periodNumber];
    final isEditing = entry != null;

    final TextEditingController subjectController = TextEditingController(
      text: isEditing && entry is! LabSession
          ? (entry is Map ? entry['subject'] : entry.toString())
          : '',
    );

    String? selectedFacultyId;
    String? selectedFacultyName;
    final TextEditingController facultyController = TextEditingController();

    if (isEditing && entry is Map) {
      selectedFacultyId = entry['faculty_id'];
      selectedFacultyName = entry['faculty_name'];
      facultyController.text = entry['faculty_name'] ?? '';
    }

    bool isLabSelected = entry is LabSession;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.8,
              maxWidth: screenWidth * 0.9,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Period Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(153, 55, 30, 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromRGBO(153, 55, 30, 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(153, 55, 30, 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isEditing ? Icons.edit : Icons.add_circle_outline,
                              color: const Color.fromRGBO(153, 55, 30, 1),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEditing ? 'Edit Period' : 'Add New Period',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(159, 160, 162, 1),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Period ${periodNumber + 1} (${timeSlots[periodNumber]})',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(153, 55, 30, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Class Type Selection
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(24, 29, 32, 1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromRGBO(153, 55, 30, 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Class Type',
                            style: TextStyle(
                              color: Color.fromRGBO(159, 160, 162, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTypeOption(
                                  icon: Icons.book,
                                  label: 'Theory',
                                  isSelected: !isLabSelected,
                                  onTap: () =>
                                      setState(() => isLabSelected = false),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTypeOption(
                                  icon: Icons.science,
                                  label: 'Lab',
                                  isSelected: isLabSelected,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showLabSessionDialog(periodNumber);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isLabSelected) ...[
                      const SizedBox(height: 24),
                      // Theory Class Details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(24, 29, 32, 1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromRGBO(153, 55, 30, 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Theory Class Details',
                              style: TextStyle(
                                color: Color.fromRGBO(159, 160, 162, 1),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: subjectController,
                              label: 'Subject',
                              icon: Icons.subject,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 16),
                            _buildFacultyField(
                              controller: facultyController,
                              label: 'Faculty',
                              onSelect: (faculty) {
                                setState(() {
                                  selectedFacultyId = faculty['id'];
                                  selectedFacultyName = faculty['name'];
                                  facultyController.text = faculty['name']!;
                                });
                              },
                              isLab: false,
                              periodNumber: periodNumber,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                const Color.fromRGBO(159, 160, 162, 1),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (subjectController.text.isNotEmpty && selectedFacultyId != null) {
                              await _addNewPeriod(
                                periodNumber,
                                subjectController.text,
                                selectedFacultyId!,
                                selectedFacultyName ?? '',
                              );
                              
                              setState(() {
                                hasUnsavedChanges = true;
                              });
                              
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Period updated successfully'),
                                    backgroundColor: Color.fromRGBO(46, 125, 50, 1),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final double iconSize = isSmallScreen ? 18.0 : 20.0;
    final double verticalPadding = isSmallScreen ? 8.0 : 12.0;
    final double fontSize = isSmallScreen ? 12.0 : 13.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(153, 55, 30, 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color.fromRGBO(153, 55, 30, 1)
                    : const Color.fromRGBO(159, 160, 162, 0.7),
                size: iconSize,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color.fromRGBO(153, 55, 30, 1)
                      : const Color.fromRGBO(159, 160, 162, 0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLabSessionDialog(int startPeriod) {
    List<String> selectedFaculty = [];
    List<String> selectedSubjects = [];
    Set<int> selectedPeriods = {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(153, 55, 30, 0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(24, 29, 32, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromRGBO(153, 55, 30, 0.3),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.people,
                              color: Color.fromRGBO(153, 55, 30, 1)),
                          SizedBox(width: 12),
                          Text(
                            'Select Faculty',
                            style: TextStyle(
                              color: Color.fromRGBO(159, 160, 162, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Multiple Faculty Selection
                    _buildMultipleFacultySection(
                      selectedFaculty: selectedFaculty,
                      onFacultyChanged: (faculties) {
                        setState(() => selectedFaculty = faculties);
                      },
                      periodNumber: startPeriod,
                    ),
                    const SizedBox(height: 16),

                    // Multiple Subject Selection
                    _buildMultipleSubjectSection(
                      selectedSubjects: selectedSubjects,
                      onSubjectsChanged: (subjects) {
                        setState(() => selectedSubjects = subjects);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Period Selection
                    _buildPeriodTimeline(
                      context,
                      selectedPeriods: selectedPeriods,
                      onPeriodTap: (period) {
                        setState(() {
                          if (selectedPeriods.contains(period)) {
                            selectedPeriods.remove(period);
                          } else {
                            selectedPeriods.add(period);
                          }
                        });
                      },
                      isMorningSlot: startPeriod <= 3,
                    ),

                    // Action Buttons with enhanced styling
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  const Color.fromRGBO(159, 160, 162, 1),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: selectedFaculty.isNotEmpty &&
                                    selectedSubjects.isNotEmpty &&
                                    selectedPeriods.isNotEmpty
                                ? () {
                                    final labSession = LabSession(
                                      subjects: selectedSubjects,
                                      facultyNames: selectedFaculty,
                                      periods: selectedPeriods.toList()..sort(),
                                    );
                                    _addLabSession(labSession);
                                    Navigator.pop(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(153, 55, 30, 1),
                              disabledBackgroundColor:
                                  const Color.fromRGBO(153, 55, 30, 0.3),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.save, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Save Lab Session',
                                  style: TextStyle(
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
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleFacultySection({
    required List<String> selectedFaculty,
    required Function(List<String>) onFacultyChanged,
    required int periodNumber,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 29, 32, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(153, 55, 30, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(153, 55, 30, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  color: Color.fromRGBO(153, 55, 30, 1),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Faculty Members',
                  style: TextStyle(
                    color: Color.fromRGBO(159, 160, 162, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${selectedFaculty.length} selected',
                  style: const TextStyle(
                    color: Color.fromRGBO(153, 55, 30, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Selected Faculty Chips
          if (selectedFaculty.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedFaculty
                  .map((faculty) => Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(153, 55, 30, 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Chip(
                          label: Text(
                            faculty,
                            style: const TextStyle(
                              color: Color.fromRGBO(159, 160, 162, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          deleteIconColor: const Color.fromRGBO(153, 55, 30, 1),
                          onDeleted: () {
                            List<String> updated = List.from(selectedFaculty);
                            updated.remove(faculty);
                            onFacultyChanged(updated);
                          },
                          elevation: 0,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Add Faculty Button
          InkWell(
            onTap: () => _showFacultySelectionDialog(
              context,
              (faculty) {
                if (!selectedFaculty.contains(faculty['name'])) {
                  List<String> updated = List.from(selectedFaculty);
                  updated.add(faculty['name']!);
                  onFacultyChanged(updated);
                }
              },
              periodNumber,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(153, 55, 30, 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color.fromRGBO(153, 55, 30, 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_circle_outline,
                    color: Color.fromRGBO(153, 55, 30, 1),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add Faculty Member',
                    style: TextStyle(
                      color: Color.fromRGBO(153, 55, 30, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleSubjectSection({
    required List<String> selectedSubjects,
    required Function(List<String>) onSubjectsChanged,
  }) {
    final TextEditingController subjectController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 29, 32, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(153, 55, 30, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with count
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(153, 55, 30, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.science,
                  color: Color.fromRGBO(153, 55, 30, 1),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Subjects',
                  style: TextStyle(
                    color: Color.fromRGBO(159, 160, 162, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${selectedSubjects.length} selected',
                  style: const TextStyle(
                    color: Color.fromRGBO(153, 55, 30, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Subject Input
          TextField(
            controller: subjectController,
            style: const TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
            decoration: InputDecoration(
              hintText: 'Enter subject name',
              hintStyle:
                  const TextStyle(color: Color.fromRGBO(159, 160, 162, 0.7)),
              filled: true,
              fillColor: const Color.fromRGBO(34, 39, 42, 1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color.fromRGBO(153, 55, 30, 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color.fromRGBO(153, 55, 30, 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color.fromRGBO(153, 55, 30, 1)),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Color.fromRGBO(153, 55, 30, 1),
                ),
                onPressed: () {
                  if (subjectController.text.isNotEmpty) {
                    List<String> updated = List.from(selectedSubjects);
                    updated.add(subjectController.text);
                    onSubjectsChanged(updated);
                    subjectController.clear();
                  }
                },
              ),
            ),
          ),
          if (selectedSubjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedSubjects
                  .map((subject) => Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(153, 55, 30, 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Chip(
                          label: Text(
                            subject,
                            style: const TextStyle(
                              color: Color.fromRGBO(159, 160, 162, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          deleteIconColor: const Color.fromRGBO(153, 55, 30, 1),
                          onDeleted: () {
                            List<String> updated = List.from(selectedSubjects);
                            updated.remove(subject);
                            onSubjectsChanged(updated);
                          },
                          elevation: 0,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromRGBO(159, 160, 162, 0.7)),
        prefixIcon: Icon(
          icon,
          color: const Color.fromRGBO(153, 55, 30, 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color.fromRGBO(153, 55, 30, 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color.fromRGBO(153, 55, 30, 1),
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyField({
    required TextEditingController controller,
    required String label,
    required Function(Map<String, String>) onSelect,
    required bool isLab,
    String? initialValue,
    required int periodNumber,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final double iconSize = isSmallScreen ? 18.0 : 22.0;
    bool sortByName = true;

    return SizedBox(
      child: InkWell(
        onTap: () {
          _showFacultySelectionDialog(context, onSelect, periodNumber);
        },
        child: TextField(
          controller: controller,
          enabled: false,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: const Color.fromRGBO(159, 160, 162, 0.7),
              fontSize: fontSize,
            ),
            prefixIcon: Icon(
              Icons.person,
              color: const Color.fromRGBO(153, 55, 30, 1),
              size: iconSize,
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: const Color.fromRGBO(153, 55, 30, 1),
              size: iconSize + 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color.fromRGBO(153, 55, 30, 0.3),
              ),
            ),
          ),
        ),
      ),
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
              'Save Timetable',
              style: TextStyle(
                color: Color.fromRGBO(159, 160, 162, 1),
              ),
            ),
          ],
        ),
        content: const Text(
          'Do you want to save the current timetable?',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              try {
                final Map<String, dynamic> formattedData = {};

                timetableData.forEach((day, periods) {
                  formattedData[day] = {};
                  periods.forEach((period, data) {
                    if (data is LabSession) {
                      formattedData[day][period.toString()] = {
                        'type': 'lab',
                        'subjects': data.subjects,
                        'facultyNames': data.facultyNames,
                        'periods': data.periods,
                      };
                    } else if (data is Map) {
                      // Check if data is Map
                      formattedData[day][period.toString()] = {
                        'type': 'theory',
                        'subject': data['subject'],
                        'faculty_id': data['faculty_id'],
                        'faculty_name': data['faculty_name'],
                      };
                    }
                  });
                });

                // Save to Firebase
                await _timetableService.saveTimetable(
                  course: widget.course,
                  year: widget.year,
                  section: widget.section,
                  timetableData: formattedData,
                );

                setState(() {
                  hasUnsavedChanges = false;
                });

                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessMessage();
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error saving timetable: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadTimetable() async {
    try {
      final data = await _timetableService.getTimetable(
        course: widget.course,
        year: widget.year,
        section: widget.section,
      );

      if (data != null && data['timetable'] != null) {
        final timetable = data['timetable'] as Map<String, dynamic>;

        setState(() {
          timetableData.clear();
          labSessions.clear();

          timetable.forEach((day, periods) {
            timetableData[day] = {};
            labSessions[day] = [];

            (periods as Map<String, dynamic>).forEach((periodStr, data) {
              final period = int.parse(periodStr);
              if (data['type'] == 'lab') {
                final labSession = LabSession(
                  subjects: List<String>.from(data['subjects']),
                  facultyNames: List<String>.from(data['facultyNames']),
                  periods: List<int>.from(data['periods']),
                );
                labSessions[day]!.add(labSession);
                timetableData[day]![period] = labSession;
              } else {
                timetableData[day]![period] = data['subject'];
              }
            });
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading timetable: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showConflicts(List<Map<String, dynamic>> conflicts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conflicting Classes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: conflicts
              .map((conflict) => ListTile(
                    title: Text(
                        '${conflict['course']} - Year ${conflict['year']}'),
                    subtitle: Text('Section ${conflict['section']}'),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewPeriod(int periodNumber, String subject, String facultyId,
      String facultyName) async {
    try {
      final data = {
        'type': 'theory',
        'subject': subject,
        'faculty_id': facultyId,
        'faculty_name': facultyName,
      };

      setState(() {
        timetableData[selectedDay!] ??= {};
        timetableData[selectedDay!]![periodNumber] =
            data; // Save complete data object
        hasUnsavedChanges = true;
      });

      await _timetableService.updateTimeSlot(
        course: widget.course,
        year: widget.year,
        section: widget.section,
        day: selectedDay!,
        period: periodNumber.toString(),
        slotData: data,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating period: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addLabSession(LabSession labSession) async {
    try {
      final data = {
        'type': 'lab',
        'subjects': labSession.subjects,
        'facultyNames': labSession.facultyNames,
        'periods': labSession.periods,
      };

      for (final period in labSession.periods) {
        await _timetableService.updateTimeSlot(
          course: widget.course,
          year: widget.year,
          section: widget.section,
          day: selectedDay!,
          period: period.toString(),
          slotData: data,
        );
      }

      setState(() {
        labSessions[selectedDay!] ??= [];
        labSessions[selectedDay!]!.add(labSession);
        for (final period in labSession.periods) {
          timetableData[selectedDay!] ??= {};
          timetableData[selectedDay!]![period] = labSession;
        }
        hasUnsavedChanges = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding lab session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPeriodTimeline(
    BuildContext context, {
    required Set<int> selectedPeriods,
    required Function(int) onPeriodTap,
    required bool isMorningSlot,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = switch (screenWidth) {
      < 360 => 24.0,
      < 400 => 28.0,
      < 600 => 32.0,
      _ => 36.0,
    };
    final fontSize = screenWidth < 400 ? 12.0 : 14.0;
    final padding = screenWidth < 400 ? 8.0 : 12.0;
    final spacing = screenWidth < 400 ? 2.0 : 4.0;
    final isSaturday = selectedDay == 'Saturday';

    // Determine number of periods based on day
    final int totalPeriods = isSaturday ? 4 : 8;
    // Create list of available periods (0-based index)
    final List<int> availablePeriods = List.generate(totalPeriods, (i) => i);

    return Container(
      margin: EdgeInsets.symmetric(vertical: padding),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 29, 32, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSaturday
              ? const Color.fromRGBO(153, 55, 30, 0.6)
              : const Color.fromRGBO(153, 55, 30, 0.3),
          width: isSaturday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSaturday ? Icons.weekend : Icons.science,
                color: const Color.fromRGBO(153, 55, 30, 1),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${isSaturday ? "Saturday" : "Select"} Lab Periods (${selectedPeriods.length}/${totalPeriods})',
                  style: TextStyle(
                    color: const Color.fromRGBO(153, 55, 30, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: availablePeriods.map((index) {
                final bool hasClass =
                    timetableData[selectedDay]?.containsKey(index) ?? false;
                final bool isSelected = selectedPeriods.contains(index);

                return AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: isSelected ? 1.1 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromRGBO(153, 55, 30, 1)
                          : (hasClass
                              ? Colors.grey.withOpacity(0.3)
                              : const Color.fromRGBO(45, 50, 54, 1)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color.fromRGBO(153, 55, 30, 1)
                            : const Color.fromRGBO(153, 55, 30, 0.3),
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              const BoxShadow(
                                color: Color.fromRGBO(153, 55, 30, 0.3),
                                blurRadius: 4,
                                spreadRadius: 0,
                              )
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onPeriodTap(index),
                        borderRadius: BorderRadius.circular(8),
                        child: Center(
                          child: Text(
                            index.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (hasClass
                                      ? const Color.fromRGBO(159, 160, 162, 0.5)
                                      : const Color.fromRGBO(159, 160, 162, 1)),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: fontSize - 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (selectedPeriods.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selected: ${(selectedPeriods.toList()..sort()).join(", ")}',
                style: TextStyle(
                  color: const Color.fromRGBO(159, 160, 162, 1),
                  fontSize: fontSize - 2,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Selected', const Color.fromRGBO(153, 55, 30, 1),
                  fontSize - 2),
              _buildLegendItem('Available', const Color.fromRGBO(45, 50, 54, 1),
                  fontSize - 2),
              _buildLegendItem(
                  'Occupied', Colors.grey.withOpacity(0.3), fontSize - 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: const Color.fromRGBO(153, 55, 30, 0.3),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color.fromRGBO(159, 160, 162, 1),
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  void _showFacultySelectionDialog(BuildContext context,
      Function(Map<String, String>) onSelect, int periodNumber) {
    final dialogHeight = MediaQuery.of(context).size.height * 0.75;
    final dialogWidth = MediaQuery.of(context).size.width * 0.9;
    final padding = MediaQuery.of(context).size.width * 0.04;
    final iconSize = MediaQuery.of(context).size.width * 0.05;
    final fontSize = MediaQuery.of(context).size.width * 0.04;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: dialogHeight,
        width: dialogWidth,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(34, 39, 42, 1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(24, 29, 32, 1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color.fromRGBO(153, 55, 30, 0.3),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.people, color: Color.fromRGBO(153, 55, 30, 1)),
                  SizedBox(width: 12),
                  Text(
                    'Select Faculty',
                    style: TextStyle(
                      color: Color.fromRGBO(159, 160, 162, 1),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search and Sort
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(
                          color: Color.fromRGBO(159, 160, 162, 1)),
                      onChanged: (value) =>
                          setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search faculty...',
                        hintStyle: const TextStyle(
                            color: Color.fromRGBO(159, 160, 162, 0.7)),
                        prefixIcon: const Icon(Icons.search,
                            color: Color.fromRGBO(153, 55, 30, 1)),
                        filled: true,
                        fillColor: const Color.fromRGBO(24, 29, 32, 1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(153, 55, 30, 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(153, 55, 30, 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(153, 55, 30, 1)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(24, 29, 32, 1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color.fromRGBO(153, 55, 30, 0.3)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        sortByName ? Icons.sort_by_alpha : Icons.category,
                        color: const Color.fromRGBO(153, 55, 30, 1),
                      ),
                      onPressed: () =>
                          setState(() => sortByName = !sortByName),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Faculty List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('faculty')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(153, 55, 30, 1),
                        strokeWidth: 3,
                      ),
                    );
                  }

                  var facultyList =
                      _getFacultyList(snapshot, searchQuery, sortByName);

                  return ListView.builder(
                    itemCount: facultyList.length,
                    itemBuilder: (context, index) {
                      final faculty = facultyList[index];

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _checkFacultyAvailability(
                            faculty['id']!, periodNumber),
                        builder: (context, availabilitySnapshot) {
                          final isEngaged = availabilitySnapshot.data != null;
                          final engagement = availabilitySnapshot.data;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(
                              bottom: 8,
                              left: isEngaged ? 8 : 16,
                              right: isEngaged ? 8 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(24, 29, 32, 1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isEngaged
                                    ? const Color.fromRGBO(153, 55, 30, 0.5)
                                    : const Color.fromRGBO(153, 55, 30, 0.3),
                                width: isEngaged ? 2 : 1,
                              ),
                              boxShadow: isEngaged
                                  ? [
                                      BoxShadow(
                                        color: const Color.fromRGBO(
                                            153, 55, 30, 0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (isEngaged) {
                                      _showEngagementWarning(
                                          context, faculty, engagement!);
                                    } else {
                                      onSelect(
                                          Map<String, String>.from(faculty));
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      ListTile(
                                        tileColor: Colors.transparent,
                                        selectedTileColor:
                                            const Color.fromRGBO(
                                                153, 55, 30, 0.2),
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              const Color.fromRGBO(
                                                  153, 55, 30, 0.2),
                                          child: Text(
                                            faculty['name']![0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Color.fromRGBO(
                                                  153, 55, 30, 1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isEngaged)
                                        AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 300),
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                          decoration: const BoxDecoration(
                                              color: Color.fromRGBO(
                                                  153, 55, 30, 0.1),
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                bottom: Radius.circular(12),
                                              )),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.schedule,
                                                color: Color.fromRGBO(
                                                    153, 55, 30, 1),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Engaged in ${engagement!['course']} ${engagement['year']}',
                                                style: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      153, 55, 30, 1),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getFacultyList(
      AsyncSnapshot<QuerySnapshot> snapshot,
      String searchQuery,
      bool sortByName) {
    var facultyList = snapshot.data!.docs.map((doc) {
      return <String, String>{
        'id': doc.id,
        'name': (doc.data() as Map)['name']?.toString() ?? '',
        'department': (doc.data() as Map)['department']?.toString() ?? '',
      };
    }).toList();

    if (searchQuery.isNotEmpty) {
      facultyList = facultyList.where((faculty) {
        return faculty['name']!
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            faculty['department']!
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
      }).toList();
    }

    facultyList.sort((a, b) => sortByName
        ? a['name']!.compareTo(b['name']!)
        : a['department']!.compareTo(b['department']!));

    return facultyList;
  }

  void _showEngagementWarning(BuildContext context, Map<String, String> faculty,
      Map<String, dynamic> engagement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Text(
          'Faculty Engagement Warning',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This faculty is engaged in another course at this time.',
              style: const TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
            ),
            const SizedBox(height: 16),
            Text(
              '${engagement['course']} - ${engagement['year']}',
              style: const TextStyle(color: Color.fromRGBO(153, 55, 30, 1)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _checkFacultyAvailability(
      String facultyId, int periodNumber) async {
    try {
      // Check all courses and sections for this faculty at this time
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('timetables')
          .where('faculty_id', isEqualTo: facultyId)
          .where('day', isEqualTo: selectedDay)
          .where('period', isEqualTo: periodNumber.toString())
          .get();

      // Check if faculty is engaged in any course at this time
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // If faculty is already engaged in any course at this time
        if (data['course'] != widget.course ||
            data['year'] != widget.year ||
            data['section'] != widget.section) {
          return {
            'course': data['course'],
            'year': data['year'],
            'section': data['section'],
            'subject': data['subject'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error checking faculty availability: $e');
      return null;
    }
  }

  void _confirmDelete() async {
    if (_lastDeletedPeriod.isNotEmpty) {
      try {
        final day = _lastDeletedPeriod['day'];
        final period = _lastDeletedPeriod['period'];
        final data = _lastDeletedPeriod['data'];

        // Delete from database
        await _timetableService.deleteTimeSlot(
          course: widget.course,
          year: widget.year,
          section: widget.section,
          day: day,
          period: period.toString(),
        );

        // If lab session, delete all related periods
        if (data is LabSession) {
          for (final labPeriod in data.periods) {
            await _timetableService.deleteTimeSlot(
              course: widget.course,
              year: widget.year,
              section: widget.section,
              day: day,
              period: labPeriod.toString(),
            );
          }
        }

        // Clear stored data after successful deletion
        _lastDeletedPeriod.clear();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting period: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _restorePeriodInDB(Map<String, dynamic> deletedPeriod) async {
    try {
      final day = deletedPeriod['day'];
      final period = deletedPeriod['period'];
      final data = deletedPeriod['data'];

      if (data is LabSession) {
        final labData = {
          'type': 'lab',
          'subjects': data.subjects,
          'facultyNames': data.facultyNames,
          'periods': data.periods,
        };

        // Restore all lab periods
        for (final labPeriod in data.periods) {
          await _timetableService.updateTimeSlot(
            course: widget.course,
            year: widget.year,
            section: widget.section,
            day: day,
            period: labPeriod.toString(),
            slotData: labData,
          );
        }
      } else {
        // Restore theory period
        final theoryData = {
          'type': 'theory',
          'subject': data['subject'],
          'faculty_id': data['faculty_id'],
          'faculty_name': data['faculty_name'],
        };

        await _timetableService.updateTimeSlot(
          course: widget.course,
          year: widget.year,
          section: widget.section,
          day: day,
          period: period.toString(),
          slotData: theoryData,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring period: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  late MediaQueryData _mediaQuery;
  late double _screenWidth;
  late double _screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mediaQuery = MediaQuery.of(context);
    _screenWidth = _mediaQuery.size.width;
    _screenHeight = _mediaQuery.size.height;
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Timetable saved successfully!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        backgroundColor: const Color.fromRGBO(46, 125, 50, 1),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: _screenHeight * 0.02,
          left: _screenWidth * 0.04,
          right: _screenWidth * 0.04,
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Add these at the top with other state variables
  String searchQuery = '';
  bool sortByName = true;
}
