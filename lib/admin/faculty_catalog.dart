import 'package:flutter/material.dart';
import 'faculty_detail_page.dart';
import '../database/faculty_db.dart';
import '../database/department_db.dart';
import '../models/faculty.dart';

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
  List<Faculty> _facultyList = [];
  List<String> _departments = [];
  bool _isLoading = true;
  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  @override
  void initState() {
    super.initState();
    _loadDepartmentsAndFaculty();
  }

  Future<void> _loadDepartmentsAndFaculty() async {
    try {
      // Fetch departments
      final departmentDB = DepartmentDatabase();
      departmentDB.getDepartments().listen((departments) {
        setState(() {
          _departments = departments;
        });
      });

      // Fetch faculty
      final facultyDB = FacultyDatabase();
      facultyDB.getAllFaculty().listen((facultyList) {
        setState(() {
          _facultyList = facultyList;
          _isLoading = false; // Set loading to false after data is loaded
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.1,
                height: width * 0.1,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  strokeWidth: width * 0.008,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Loading Faculty Data...',
                style: TextStyle(
                  color: textColor,
                  fontSize: width * 0.04,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.people_alt, color: accentColor, size: width * 0.07),
            SizedBox(width: width * 0.03),
            Text(
              'Faculty Catalog',
              style: TextStyle(
                color: textColor,
                fontSize: width * 0.055,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(width * 0.03),
              border: Border.all(color: accentColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: selectedDepartment,
              decoration: InputDecoration(
                labelText: 'Select Department',
                labelStyle: TextStyle(
                  color: textColor,
                  fontSize: width * 0.04,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.02,
                ),
                border: InputBorder.none,
              ),
              dropdownColor: cardColor,
              style: TextStyle(
                color: textColor,
                fontSize: width * 0.04,
              ),
              icon: Icon(Icons.arrow_drop_down, color: accentColor),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('All Departments'),
                ),
                ..._departments.map((dept) {
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
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.01,
              ),
              itemCount: _getFilteredFacultyList().length,
              itemBuilder: (context, index) {
                final faculty = _getFilteredFacultyList()[index];
                return Container(
                  margin: EdgeInsets.only(bottom: height * 0.02),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardColor,
                        cardColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(width * 0.03),
                    border: Border.all(color: accentColor.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(width * 0.03),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FacultyDetailPage(faculty: faculty),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.04),
                        child: Row(
                          children: [
                            Container(
                              width: width * 0.15,
                              height: width * 0.15,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor.withOpacity(0.2),
                                    accentColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  faculty.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: width * 0.06,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: width * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    faculty.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.01),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.02,
                                      vertical: height * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.01),
                                    ),
                                    child: Text(
                                      faculty.designation,
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: width * 0.035,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: accentColor,
                              size: width * 0.05,
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
    );
  }

  List<Faculty> _getFilteredFacultyList() {
    if (selectedDepartment == null) {
      return _facultyList;
    }
    return _facultyList
        .where((faculty) => faculty.department == selectedDepartment)
        .toList();
  }
}
