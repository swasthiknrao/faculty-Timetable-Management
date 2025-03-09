import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/timetable_database.dart';
import '../models/timetable_entry.dart';

class ViewSchedules extends StatefulWidget {
  const ViewSchedules({super.key});

  @override
  State<ViewSchedules> createState() => _ViewSchedulesState();
}

class _ViewSchedulesState extends State<ViewSchedules> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TimetableDatabase _timetableDb = TimetableDatabase();

  String? selectedCourse;
  String? selectedYear;
  String? selectedSection;
  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      // First get all courses from the courses collection
      final coursesSnapshot = await _firestore.collection('courses').get();

      setState(() {
        courses = coursesSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'name': data['name'] as String,
            'years': List<String>.from(data['years'] ?? []),
            'sections': List<String>.from(data['sections'] ?? []),
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading courses: $e');
    }
  }

  Future<List<String>> _getYearsForCourse(String course) async {
    try {
      // Find the course in our loaded courses list
      final courseData = courses.firstWhere(
        (c) => c['name'] == course,
        orElse: () => {'years': []},
      );
      return List<String>.from(courseData['years'] ?? []);
    } catch (e) {
      debugPrint('Error getting years: $e');
      return [];
    }
  }

  Future<List<String>> _getSectionsForCourseAndYear(
      String course, String year) async {
    try {
      // Find the course in our loaded courses list
      final courseData = courses.firstWhere(
        (c) => c['name'] == course,
        orElse: () => {'sections': []},
      );

      // Get sections from the course data
      final sections = List<String>.from(courseData['sections'] ?? []);

      // Verify which sections have timetable entries for this year
      final verifiedSections = <String>[];

      for (final section in sections) {
        final docRef = _firestore
            .collection('timetables')
            .doc('${course}_${year}_$section');

        final doc = await docRef.get();
        if (doc.exists) {
          verifiedSections.add(section);
        }
      }

      return verifiedSections;
    } catch (e) {
      debugPrint('Error getting sections: $e');
      return [];
    }
  }

  // Add a refresh method
  Future<void> refreshData() async {
    await _loadCourses();
    if (selectedCourse != null) {
      final years = await _getYearsForCourse(selectedCourse!);
      if (!years.contains(selectedYear)) {
        setState(() => selectedYear = null);
      }

      if (selectedYear != null) {
        final sections =
            await _getSectionsForCourseAndYear(selectedCourse!, selectedYear!);
        if (!sections.contains(selectedSection)) {
          setState(() => selectedSection = null);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 29, 32, 1),
      appBar: AppBar(
        title: const Text(
          'View Schedules',
          style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
        ),
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color.fromRGBO(34, 39, 42, 1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDropdown(
                      'Course',
                      courses.map((e) => e['name'] as String).toList(),
                      selectedCourse,
                      (value) {
                        setState(() {
                          selectedCourse = value;
                          selectedYear = null;
                          selectedSection = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedCourse != null)
                      FutureBuilder<List<String>>(
                        future: _getYearsForCourse(selectedCourse!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return _buildDropdown(
                              'Year',
                              snapshot.data!,
                              selectedYear,
                              (value) {
                                setState(() {
                                  selectedYear = value;
                                  selectedSection = null;
                                });
                              },
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    if (selectedCourse != null && selectedYear != null)
                      FutureBuilder<List<String>>(
                        future: _getSectionsForCourseAndYear(
                            selectedCourse!, selectedYear!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return _buildDropdown(
                              'Section',
                              snapshot.data!,
                              selectedSection,
                              (value) {
                                setState(() => selectedSection = value);
                              },
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (selectedCourse != null &&
                selectedYear != null &&
                selectedSection != null)
              Expanded(
                child: StreamBuilder<List<TimetableEntry>>(
                  stream: _timetableDb.getTimetableEntries(
                    selectedCourse!,
                    selectedYear!,
                    selectedSection!,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading timetable'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return _buildTimetableView(snapshot.data!);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color.fromRGBO(159, 160, 162, 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(24, 29, 32, 1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color.fromRGBO(153, 55, 30, 0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color.fromRGBO(24, 29, 32, 1),
              style: const TextStyle(
                color: Color.fromRGBO(159, 160, 162, 1),
              ),
              hint: Text('Select $label'),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimetableView(List<TimetableEntry> entries) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return Card(
      color: const Color.fromRGBO(34, 39, 42, 1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Table(
          border: TableBorder.all(
            color: const Color.fromRGBO(153, 55, 30, 0.3),
          ),
          children: [
            TableRow(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(153, 55, 30, 0.1),
              ),
              children: [
                const TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Day/Period',
                      style: TextStyle(
                        color: Color.fromRGBO(159, 160, 162, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ...List.generate(
                    8,
                    (index) => TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Period $index',
                              style: const TextStyle(
                                color: Color.fromRGBO(159, 160, 162, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
              ],
            ),
            ...List.generate(6, (dayIndex) {
              final dayEntries =
                  entries.where((e) => e.dayOfWeek == dayIndex + 1).toList();
              return TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        days[dayIndex],
                        style: const TextStyle(
                          color: Color.fromRGBO(159, 160, 162, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(8, (periodIndex) {
                    final entry = dayEntries.firstWhere(
                      (e) => e.period == periodIndex,
                      orElse: () => TimetableEntry(
                        facultyId: '',
                        className: '',
                        subject: '',
                        dayOfWeek: dayIndex + 1,
                        period: periodIndex,
                      ),
                    );
                    return TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.subject.isNotEmpty) ...[
                              Text(
                                entry.subject,
                                style: const TextStyle(
                                  color: Color.fromRGBO(159, 160, 162, 1),
                                ),
                              ),
                              Text(
                                entry.facultyId,
                                style: const TextStyle(
                                  color: Color.fromRGBO(159, 160, 162, 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              if (entry.isLab)
                                Text(
                                  'Lab (${entry.labDuration})',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(153, 55, 30, 1),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
