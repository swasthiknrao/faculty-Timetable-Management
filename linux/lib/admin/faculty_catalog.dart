import 'package:flutter/material.dart';
import 'faculty_detail_page.dart';

class FacultyCatalog extends StatefulWidget {
  final List<Map<String, dynamic>> facultyData;
  final List<String> departments;

  const FacultyCatalog({
    super.key,
    required this.facultyData,
    required this.departments,
  });

  @override
  State<FacultyCatalog> createState() => _FacultyCatalogState();
}

class _FacultyCatalogState extends State<FacultyCatalog> {
  String? selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 29, 32, 1),
      appBar: AppBar(
        title: const Text(
          'Faculty Catalog',
          style: TextStyle(
            color: Color.fromRGBO(159, 160, 162, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(24, 29, 32, 1),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(153, 55, 30, 1),
        ),
      ),
      body: Column(
        children: [
          _buildDepartmentDropdown(),
          Expanded(
            child: _buildFacultyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        value: selectedDepartment,
        decoration: InputDecoration(
          labelText: 'Select Department',
          labelStyle: const TextStyle(
            color: Color.fromRGBO(159, 160, 162, 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromRGBO(153, 55, 30, 1),
            ),
          ),
        ),
        dropdownColor: const Color.fromRGBO(32, 38, 42, 1),
        style: const TextStyle(
          color: Color.fromRGBO(159, 160, 162, 1),
        ),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('All Departments'),
          ),
          ...widget.departments.map((dept) {
            return DropdownMenuItem(
              value: dept,
              child: Text(dept),
            );
          }),
        ],
        onChanged: (value) {
          setState(() {
            selectedDepartment = value;
          });
        },
      ),
    );
  }

  Widget _buildFacultyList() {
    final filteredFaculty = selectedDepartment == null
        ? widget.facultyData
        : widget.facultyData
            .where((faculty) => faculty['department'] == selectedDepartment)
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFaculty.length,
      itemBuilder: (context, index) {
        final faculty = filteredFaculty[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color.fromRGBO(32, 38, 42, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color.fromRGBO(153, 55, 30, 1),
              width: 0.5,
            ),
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FacultyDetailPage(faculty: faculty),
                ),
              );
            },
            title: Text(
              faculty['name'],
              style: const TextStyle(
                color: Color.fromRGBO(159, 160, 162, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              faculty['designation'],
              style: TextStyle(
                color: const Color.fromRGBO(159, 160, 162, 1).withOpacity(0.7),
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color.fromRGBO(153, 55, 30, 1),
              size: 16,
            ),
          ),
        );
      },
    );
  }
}
