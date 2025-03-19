import 'package:flutter/material.dart';

class TimetableViewer extends StatefulWidget {
  final Map<String, dynamic> timetableData;
  const TimetableViewer({super.key, required this.timetableData});

  @override
  State<TimetableViewer> createState() => _TimetableViewerState();
}

class _TimetableViewerState extends State<TimetableViewer> {
  String? selectedCourse;
  String? selectedYear;
  String? selectedSection;

  // Sample data structure
  final Map<String, Map<String, List<String>>> courseData = {
    'BBA': {
      '1st Year': ['A', 'B', 'C'],
      '2nd Year': ['A', 'B', 'C'],
      '3rd Year': ['A', 'B'],
    },
    'BCA': {
      '1st Year': ['A', 'B'],
      '2nd Year': ['A', 'B'],
      '3rd Year': ['A', 'B'],
    },
    'BCom': {
      '1st Year': ['A', 'B', 'C', 'D'],
      '2nd Year': ['A', 'B', 'C'],
      '3rd Year': ['A', 'B', 'C'],
    },
    'BSc': {
      '1st Year': ['A', 'B'],
      '2nd Year': ['A', 'B'],
      '3rd Year': ['A'],
    },
  };

  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const cardColor = Color.fromRGBO(32, 38, 42, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Timetable Viewer',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: accentColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: _buildCurrentView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    if (selectedCourse == null) {
      return _buildCourseGrid();
    } else if (selectedYear == null) {
      return _buildYearGrid();
    } else if (selectedSection == null) {
      return _buildSectionGrid();
    } else {
      return _buildTimetable();
    }
  }

  Widget _buildCourseGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Course',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: courseData.length,
            itemBuilder: (context, index) {
              final course = courseData.keys.elementAt(index);
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentColor.withOpacity(0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => setState(() => selectedCourse = course),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  title: Text(
                    course,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${courseData[course]!.length} Years',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: accentColor.withOpacity(0.7),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: accentColor, size: 28),
              onPressed: () => setState(() => selectedCourse = null),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCourse!,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Select Year',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: courseData[selectedCourse]!.length,
            itemBuilder: (context, index) {
              final year = courseData[selectedCourse]!.keys.elementAt(index);
              final sections = courseData[selectedCourse]![year]!;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentColor.withOpacity(0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => setState(() => selectedYear = year),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        year[0],
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    year,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${sections.length} Sections',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: accentColor.withOpacity(0.7),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: accentColor, size: 28),
              onPressed: () => setState(() => selectedYear = null),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$selectedCourse - $selectedYear',
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Select Section',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: courseData[selectedCourse]![selectedYear]!.length,
            itemBuilder: (context, index) {
              final section = courseData[selectedCourse]![selectedYear]![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentColor.withOpacity(0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => setState(() => selectedSection = section),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        section,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'Section $section',
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: accentColor.withOpacity(0.7),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimetable() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final periods = ['0', '1', '2', '3', '4', '5', '6', '7'];
    final times = [
      '8:50 - 9:40', // Period 0 (optional)
      '9:45 - 10:35', // Period 1
      '10:40 - 11:30', // Period 2
      '11:35 - 12:25', // Period 3
      '1:05 - 1:55', // Period 4
      '2:00 - 2:50', // Period 5
      '2:55 - 3:45', // Period 6
      '3:50 - 4:40', // Period 7 (optional)
    ];

    // Helper function to determine if period should be shown
    bool showPeriod(String day, int periodIndex) {
      if (day == 'SAT') {
        // Show 0th period and periods 1-3 for Saturday
        return periodIndex == 0 || (periodIndex > 0 && periodIndex < 4);
      }
      // For other days, show all periods (0-7)
      // Periods 0 and 7 are shown but marked as optional
      return true;
    }

    // Helper function to determine if period is optional
    bool isOptionalPeriod(int periodIndex) {
      return periodIndex == 0 || periodIndex == 7;
    }

    // Add this helper function to check if it's a lab period
    bool isLabPeriod(String day, int periodIndex) {
      if (selectedCourse == null ||
          selectedYear == null ||
          selectedSection == null) {
        return false;
      }

      // Get the timetable for current selection
      final timetable = widget.timetableData[selectedCourse]?[selectedYear]
          ?[selectedSection]?[day];
      if (timetable == null) return false;

      // Check if this period is part of a lab
      final currentPeriod = timetable[periodIndex.toString()];
      if (currentPeriod == null) return false;

      // A period is a lab period if:
      // 1. It's marked as a lab in the data
      // 2. It spans multiple periods
      return currentPeriod['isLab'] == true || currentPeriod['duration'] > 1;
    }

    // Add this helper function to get cell width for lab periods
    double getCellWidth(String day, int periodIndex, bool isLab) {
      if (isLab &&
          showPeriod(day, periodIndex) &&
          showPeriod(day, periodIndex + 1)) {
        return 2; // Take up space of 2 periods
      }
      return 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: accentColor),
              onPressed: () => setState(() => selectedSection = null),
            ),
            Expanded(
              child: Text(
                '$selectedCourse - $selectedYear - Section $selectedSection',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            color: cardColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: accentColor.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        1.8, // Increased width for more periods
                    child: Column(
                      children: [
                        // Period Headers
                        Row(
                          children: [
                            // Day header cell
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'DAY',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            ...List.generate(
                              periods.length,
                              (index) => Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isOptionalPeriod(index)
                                        ? accentColor.withOpacity(0.05)
                                        : accentColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: accentColor.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        periods[index],
                                        style: TextStyle(
                                          color: isOptionalPeriod(index)
                                              ? accentColor.withOpacity(0.7)
                                              : accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        times[index],
                                        style: TextStyle(
                                          color: isOptionalPeriod(index)
                                              ? textColor.withOpacity(0.5)
                                              : textColor.withOpacity(0.7),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Day rows
                        ...days.map((day) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  // Day cell
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: const TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Period cells
                                  ...List.generate(
                                    8,
                                    (index) {
                                      if (showPeriod(day, index)) {
                                        final isLab = isLabPeriod(day, index);
                                        // Skip the next cell if this is a lab period
                                        if (index > 0 &&
                                            isLabPeriod(day, index - 1)) {
                                          return const SizedBox.shrink();
                                        }

                                        return Expanded(
                                          flex: getCellWidth(day, index, isLab)
                                              .toInt(),
                                          child: Container(
                                            height: 70,
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isOptionalPeriod(index)
                                                  ? cardColor.withOpacity(0.5)
                                                  : cardColor,
                                              border: Border.all(
                                                color: accentColor
                                                    .withOpacity(0.2),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child:
                                                _buildPeriodContent(day, index),
                                          ),
                                        );
                                      }
                                      return Expanded(
                                        child: Container(
                                          height: 70,
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          decoration: BoxDecoration(
                                            color: backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodContent(String day, int index) {
    // Gets the timetable data for selected course, year, section and day
    final timetable = widget.timetableData[selectedCourse]?[selectedYear]
        ?[selectedSection]?[day];
    if (timetable == null) return const SizedBox.shrink();

    // Gets the specific period data
    final periodData = timetable[index.toString()];
    if (periodData == null) return const SizedBox.shrink();

    if (periodData['isLab'] == true) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            periodData['subject'] ?? 'Lab Subject', // Shows actual lab subject
            style: const TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          ...List<String>.from(periodData['faculty'] ?? []).map(
            // Shows all lab faculty
            (faculty) => Text(
              faculty,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            periodData['subject'] ?? 'Subject', // Shows actual subject
            style: const TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            periodData['faculty']?.first ?? 'Teacher', // Shows actual faculty
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }
}
