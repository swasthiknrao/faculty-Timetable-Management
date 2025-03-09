import 'package:flutter/material.dart';
import '../models/faculty.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class FacultyDetailPage extends StatelessWidget {
  final Faculty faculty;

  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  const FacultyDetailPage({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('faculty')
          .doc(faculty.id)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return _buildLoadingState(context);
        }

        final facultyData = snapshot.data!.data() as Map<String, dynamic>;
        return _buildMainContent(context, facultyData);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: accentColor, size: 48),
            SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
            SizedBox(height: 16),
            Text(
              'Loading faculty data...',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, Map<String, dynamic> facultyData) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text('Faculty Profile', style: TextStyle(color: textColor)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: cardColor,
              padding: EdgeInsets.all(width * 0.06),
              child: Column(
                children: [
                  // Profile Image
                  Hero(
                    tag: 'profile_${faculty.id}',
                    child: CircleAvatar(
                      radius: width * 0.15,
                      backgroundColor: accentColor,
                      child: CircleAvatar(
                        radius: width * 0.14,
                        backgroundColor: cardColor,
                        child: Text(
                          facultyData['name']?[0] ?? 'U',
                          style: TextStyle(
                            fontSize: width * 0.12,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  // Name
                  Text(
                    facultyData['name'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.01),
                  // Department
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      facultyData['department'] ?? '',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                children: [
                  // Stats Row
                  Container(
                    padding: EdgeInsets.all(width * 0.04),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(width * 0.04),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                            'Experience',
                            _formatExperience(facultyData['experience']),
                            Icons.timeline),
                        Container(
                            height: height * 0.04,
                            width: 1,
                            color: accentColor.withOpacity(0.3)),
                        _buildStat(
                            'DOB',
                            _formatDate(facultyData['dateOfBirth']),
                            Icons.cake),
                        Container(
                            height: height * 0.04,
                            width: 1,
                            color: accentColor.withOpacity(0.3)),
                        _buildStat('Designation',
                            facultyData['designation'] ?? '', Icons.work),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  _buildQualificationsCard(context, facultyData),
                  SizedBox(height: height * 0.02),
                  _buildSubjectsCard(context, facultyData),
                  SizedBox(height: height * 0.02),
                  _buildContactCard(context, facultyData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
      BuildContext context, Map<String, dynamic> facultyData) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Experience', '${facultyData['experience'] ?? 0} Yrs',
              Icons.timeline),
          Container(
              height: height * 0.04,
              width: 1,
              color: accentColor.withOpacity(0.3)),
          _buildStat(
              'DOB', _formatDate(facultyData['dateOfBirth']), Icons.cake),
          Container(
              height: height * 0.04,
              width: 1,
              color: accentColor.withOpacity(0.3)),
          _buildStat(
              'Designation', facultyData['designation'] ?? '', Icons.work),
        ],
      ),
    );
  }

  Widget _buildContactCard(
      BuildContext context, Map<String, dynamic> facultyData) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildContactRow(Icons.email, 'Email', facultyData['email'] ?? ''),
          Divider(color: accentColor.withOpacity(0.2), height: 20),
          _buildContactRow(Icons.phone, 'Phone', facultyData['phone'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildQualificationsCard(
      BuildContext context, Map<String, dynamic> facultyData) {
    final width = MediaQuery.of(context).size.width;
    final qualifications =
        facultyData['qualificationsList'] as List<dynamic>? ?? [];

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: accentColor),
              SizedBox(width: 12),
              Text(
                'Qualifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...qualifications.map((qual) {
            final qualification = qual as Map<String, dynamic>;
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    qualification['degree'] ?? '',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    qualification['year'] ?? '',
                    style: TextStyle(color: accentColor),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubjectsCard(
      BuildContext context, Map<String, dynamic> facultyData) {
    final width = MediaQuery.of(context).size.width;
    final subjects = List<String>.from(facultyData['subjects'] ?? []);

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.book, color: accentColor),
              SizedBox(width: 12),
              Text(
                'Subjects',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subjects
                .map((subject) => Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        subject,
                        style: TextStyle(color: textColor),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: accentColor),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: textColor)),
        Text(value,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: accentColor),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: textColor)),
            Text(value, style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final DateTime dateTime = date is String ? DateTime.parse(date) : date;
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatExperience(dynamic experience) {
    if (experience == null) return '0 Yrs';

    // If experience is already a string and contains 'year' or 'yr', return as is
    if (experience is String &&
        (experience.toLowerCase().contains('year') ||
            experience.toLowerCase().contains('yr'))) {
      return experience;
    }

    // Convert to string and check if it ends with common year indicators
    final expStr = experience.toString().toLowerCase();
    if (expStr.endsWith('years') ||
        expStr.endsWith('yrs') ||
        expStr.endsWith('year') ||
        expStr.endsWith('yr')) {
      return experience.toString();
    }

    // If it's just a number, add 'Yrs'
    return '$experience Yrs';
  }
}

class GlassMorphicBadge extends StatelessWidget {
  final Widget child;

  const GlassMorphicBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
