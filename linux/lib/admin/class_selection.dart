import 'package:flutter/material.dart';
import 'timetable_management.dart';
import '../utils/slide_route.dart';

class ClassSelection extends StatefulWidget {
  const ClassSelection({super.key});

  @override
  State<ClassSelection> createState() => _ClassSelectionState();
}

class _ClassSelectionState extends State<ClassSelection> {
  final List<String> courses = ['BCA', 'BBA', 'BSc', 'BCom'];
  final List<String> years = ['1st Year', '2nd Year', '3rd Year'];
  final List<String> sections = ['A', 'B', 'C'];

  String? selectedCourse;
  String? selectedYear;
  String? selectedSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 29, 32, 1),
      appBar: AppBar(
        title: const Text(
          'Select Class',
          style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
        ),
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              color: const Color.fromRGBO(34, 39, 42, 1),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.class_,
                      size: 64,
                      color: Color.fromRGBO(153, 55, 30, 1),
                    ),
                    const SizedBox(height: 24),
                    _buildDropdown(
                      'Course',
                      courses,
                      selectedCourse,
                      (value) => setState(() => selectedCourse = value),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'Year',
                      years,
                      selectedYear,
                      (value) => setState(() => selectedYear = value),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'Section',
                      sections,
                      selectedSection,
                      (value) => setState(() => selectedSection = value),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _canProceed()
                          ? () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: TimetableManagement(
                                    course: selectedCourse!,
                                    year: selectedYear!,
                                    section: selectedSection!,
                                  ),
                                  direction: AxisDirection.left,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
                        foregroundColor: const Color.fromRGBO(159, 160, 162, 1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Create Timetable',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
              hint: Text(
                'Select $label',
                style: const TextStyle(
                  color: Color.fromRGBO(159, 160, 162, 0.5),
                ),
              ),
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

  bool _canProceed() {
    return selectedCourse != null &&
        selectedYear != null &&
        selectedSection != null;
  }
}
