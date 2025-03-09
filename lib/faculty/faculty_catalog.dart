import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'faculty_profile_page.dart';

class FacultyCatalog extends StatelessWidget {
  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  const FacultyCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 4,
        title: Row(
          children: [
            Icon(Icons.people_alt, color: accentColor, size: width * 0.07),
            SizedBox(width: width * 0.03),
            Text(
              'Faculty Directory',
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.055,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: textColor),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('faculty').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      color: accentColor, size: width * 0.15),
                  SizedBox(height: height * 0.02),
                  Text(
                    'Error loading data',
                    style: TextStyle(
                      color: textColor,
                      fontSize: width * 0.04,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
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
                    'Loading faculty data...',
                    style: TextStyle(
                      color: textColor,
                      fontSize: width * 0.04,
                    ),
                  ),
                ],
              ),
            );
          }

          final faculties = snapshot.data?.docs ?? [];

          if (faculties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      color: textColor, size: width * 0.15),
                  SizedBox(height: height * 0.02),
                  Text(
                    'No faculty members found',
                    style: TextStyle(
                      color: textColor,
                      fontSize: width * 0.04,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.02,
            ),
            itemCount: faculties.length,
            itemBuilder: (context, index) {
              final faculty = faculties[index].data() as Map<String, dynamic>;

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
                  borderRadius: BorderRadius.circular(width * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(width * 0.04),
                    onTap: () => _showFacultyProfile(context, faculty),
                    child: Padding(
                      padding: EdgeInsets.all(width * 0.04),
                      child: Row(
                        children: [
                          // Profile Image
                          Container(
                            width: width * 0.2,
                            height: width * 0.2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  accentColor.withOpacity(0.2),
                                  accentColor.withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(
                                color: accentColor.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: faculty['profileImageUrl'] != null
                                  ? Image.network(
                                      faculty['profileImageUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          _buildInitial(faculty['name'], width),
                                    )
                                  : _buildInitial(faculty['name'], width),
                            ),
                          ),
                          SizedBox(width: width * 0.04),

                          // Faculty Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faculty['name'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.045,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.03,
                                    vertical: height * 0.006,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        accentColor.withOpacity(0.2),
                                        accentColor.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(width * 0.02),
                                    border: Border.all(
                                      color: accentColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    faculty['designation'] ?? 'Faculty',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: width * 0.035,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(width * 0.015),
                                      decoration: BoxDecoration(
                                        color: textColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.business,
                                        color: textColor,
                                        size: width * 0.04,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      faculty['department'] ?? 'Department',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: width * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // View Profile Button
                          Container(
                            padding: EdgeInsets.all(width * 0.025),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor.withOpacity(0.2),
                                  accentColor.withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: accentColor,
                              size: width * 0.045,
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
      ),
    );
  }

  Widget _buildInitial(String? name, double width) {
    return Center(
      child: Text(
        (name ?? 'U')[0].toUpperCase(),
        style: TextStyle(
          color: accentColor,
          fontSize: width * 0.08,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFacultyProfile(BuildContext context, Map<String, dynamic> faculty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacultyProfilePage(
          facultyName: faculty['name'] ?? '',
          department: faculty['department'] ?? '',
          designation: faculty['designation'] ?? '',
          experience: faculty['experience']?.toString() ?? '',
          qualifications: faculty['qualifications'] ?? '',
          subjects: List<String>.from(faculty['subjects'] ?? []),
          email: faculty['email'] ?? '',
          phone: faculty['phone'] ?? '',
          dateOfBirth: faculty['dateOfBirth'] != null
              ? DateTime.parse(faculty['dateOfBirth'])
              : DateTime.now(),
        ),
      ),
    );
  }
}
