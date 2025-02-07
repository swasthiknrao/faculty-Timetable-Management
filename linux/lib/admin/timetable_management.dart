import 'package:flutter/material.dart';

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
  final String subject1;
  final String? subject2; // Optional for BSc
  final List<int> periods;
  final String faculty1;
  final String? faculty2; // Optional for BSc

  LabSession({
    required this.subject1,
    this.subject2,
    required this.periods,
    required this.faculty1,
    this.faculty2,
  });

  bool get isDoubleFaculty => faculty2 != null;
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
        final isOptionalHour = periodNumber == 0 || periodNumber == 7;
        final entry = timetableData[selectedDay]?[periodNumber];
        final isLabSession = entry is LabSession;

        if (isLabSession) {
          final labSession = entry;
          if (labSession.periods.first != periodNumber) {
            return const SizedBox.shrink(); // Hide subsequent lab periods
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isOptionalHour
              ? const Color.fromRGBO(24, 29, 32, 0.7)
              : const Color.fromRGBO(24, 29, 32, 1),
          child: ListTile(
            onTap: () => _showAddPeriodDialog(periodNumber),
            leading: SizedBox(
              width: 80,
              child: Row(
                children: [
                  Icon(
                    isOptionalHour ? Icons.stars : Icons.access_time,
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
                  ),
                ],
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLabSession
                      ? (entry).isDoubleFaculty
                          ? '${(entry).subject1} & ${(entry).subject2} (Lab)\n'
                              'Faculty: ${(entry).faculty1}, ${(entry).faculty2}'
                          : '${(entry).subject1} (Lab)\nFaculty: ${(entry).faculty1}'
                      : entry?.toString() ?? 'No subject assigned',
                  style: TextStyle(
                    color: const Color.fromRGBO(159, 160, 162, 1),
                    fontStyle:
                        isOptionalHour ? FontStyle.italic : FontStyle.normal,
                    fontWeight:
                        isLabSession ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isLabSession)
                  Text(
                    'Lab Hours: ${(entry).periods.map((p) => (p + 1).toString()).join(", ")}',
                    style: const TextStyle(
                      color: Color.fromRGBO(153, 55, 30, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
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
        );
      },
    );
  }

  void _showAddPeriodDialog(int periodNumber) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController facultyController = TextEditingController();
    final isOptionalHour = periodNumber == 0 || periodNumber == 7;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isOptionalHour ? Icons.stars : Icons.edit,
                        color: const Color.fromRGBO(153, 55, 30, 1),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Period ${periodNumber == 0 ? '0' : periodNumber == 1 ? '1' : periodNumber == 2 ? '2' : periodNumber == 3 ? '3' : periodNumber == 4 ? '4' : periodNumber == 5 ? '5' : periodNumber == 6 ? '6' : '7'}${isOptionalHour ? ' (Optional)' : ''}\n${timeSlots[periodNumber]}',
                          style: const TextStyle(
                            color: Color.fromRGBO(159, 160, 162, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedDay!,
                    style: const TextStyle(
                      color: Color.fromRGBO(153, 55, 30, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDialogTextField(
                    controller: subjectController,
                    label: 'Subject',
                    icon: Icons.book,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: facultyController,
                    label: 'Faculty Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color.fromRGBO(159, 160, 162, 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (hasLabSessions) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showLabSessionDialog(periodNumber);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(153, 55, 30, 1),
                              foregroundColor:
                                  const Color.fromRGBO(159, 160, 162, 1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(
                              Icons.science,
                              color: Color.fromRGBO(159, 160, 162, 1),
                            ),
                            label: const Text(
                              'Add Lab Session',
                              style: TextStyle(
                                color: Color.fromRGBO(159, 160, 162, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (subjectController.text.isNotEmpty) {
                              setState(() {
                                timetableData[selectedDay!] ??= {};
                                timetableData[selectedDay!]![periodNumber] =
                                    subjectController.text;
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(153, 55, 30, 1),
                            foregroundColor:
                                const Color.fromRGBO(159, 160, 162, 1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(
                            Icons.save,
                            color: Color.fromRGBO(159, 160, 162, 1),
                          ),
                          label: const Text(
                            'Add Theory',
                            style: TextStyle(
                              color: Color.fromRGBO(159, 160, 162, 1),
                              fontWeight: FontWeight.bold,
                            ),
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

  void _showLabSessionDialog(int startPeriod) {
    final TextEditingController subject1Controller = TextEditingController();
    final TextEditingController subject2Controller = TextEditingController();
    final TextEditingController faculty1Controller = TextEditingController();
    final TextEditingController faculty2Controller = TextEditingController();

    final bool isBCA = widget.course == 'BCA';
    List<int> selectedPeriods = [];
    bool isMorningSlot = startPeriod <= 3;
    selectedPeriods = isMorningSlot ? morningLabSlots : afternoonLabSlots;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.science,
                      color: Color.fromRGBO(153, 55, 30, 1),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add ${isMorningSlot ? "Morning" : "Afternoon"} Lab Session\n'
                        '${isMorningSlot ? "8:50 - 12:25" : "1:05 - 4:40"}',
                        style: const TextStyle(
                          color: Color.fromRGBO(159, 160, 162, 1),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: subject1Controller,
                  label: isBCA ? 'Lab Subject 1' : 'Lab Subject',
                  icon: Icons.science,
                ),
                if (isBCA) ...[
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: subject2Controller,
                    label: 'Lab Subject 2',
                    icon: Icons.science,
                  ),
                ],
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: faculty1Controller,
                  label: isBCA ? 'Faculty 1' : 'Faculty',
                  icon: Icons.person,
                ),
                if (isBCA) ...[
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: faculty2Controller,
                    label: 'Faculty 2',
                    icon: Icons.person,
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Lab Hours',
                  style: TextStyle(
                    color: Color.fromRGBO(153, 55, 30, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Periods: ${selectedPeriods.map((p) => p.toString()).join(", ")}',
                  style: const TextStyle(
                    color: Color.fromRGBO(159, 160, 162, 1),
                    fontSize: 14,
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
                        bool isValid = subject1Controller.text.isNotEmpty &&
                            faculty1Controller.text.isNotEmpty;

                        if (isBCA) {
                          isValid = isValid &&
                              subject2Controller.text.isNotEmpty &&
                              faculty2Controller.text.isNotEmpty;
                        }

                        if (isValid) {
                          final labSession = LabSession(
                            subject1: subject1Controller.text,
                            subject2: isBCA ? subject2Controller.text : null,
                            periods: selectedPeriods,
                            faculty1: faculty1Controller.text,
                            faculty2: isBCA ? faculty2Controller.text : null,
                          );
                          setState(() {
                            labSessions[selectedDay!] ??= [];
                            labSessions[selectedDay!]!.add(labSession);
                            for (final period in selectedPeriods) {
                              timetableData[selectedDay!] ??= {};
                              timetableData[selectedDay!]![period] = labSession;
                            }
                            hasUnsavedChanges = true;
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
                        foregroundColor: const Color.fromRGBO(159, 160, 162, 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Save Lab Session',
                        style: TextStyle(
                          color: Color.fromRGBO(159, 160, 162, 1),
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
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Color.fromRGBO(159, 160, 162, 1),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color.fromRGBO(153, 55, 30, 1),
        ),
        filled: true,
        fillColor: const Color.fromRGBO(24, 29, 32, 1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromRGBO(153, 55, 30, 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromRGBO(153, 55, 30, 1),
            width: 2,
          ),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color.fromRGBO(153, 55, 30, 1),
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
            onPressed: () {
              // TODO: Implement actual save functionality
              setState(() {
                hasUnsavedChanges = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Timetable saved successfully!'),
                  backgroundColor: Color.fromRGBO(153, 55, 30, 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
            ),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
