import 'package:flutter/material.dart';
import 'dart:math' as math;

class FacultyProfilePage extends StatelessWidget {
  final String facultyName;
  final String department;
  final String designation;
  final String experience;
  final String qualifications;
  final List<String> subjects;
  final String email;
  final String phone;

  const FacultyProfilePage({
    super.key,
    required this.facultyName,
    required this.department,
    required this.designation,
    required this.experience,
    required this.qualifications,
    required this.subjects,
    required this.email,
    required this.phone,
  });

  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Widget buildInfoSection() {
      return Column(
        children: [
          _buildInfoItem(context, 'Email', email, Icons.email),
          _buildInfoItem(context, 'Phone', phone, Icons.phone),
          _buildInfoItem(context, 'Designation', designation, Icons.work),
          _buildInfoItem(context, 'Experience', experience, Icons.access_time),
          _buildInfoItem(
              context, 'Qualifications', qualifications, Icons.school),
          _buildSubjectsList(context, subjects),
        ],
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Animated background patterns
          ...List.generate(5, (index) {
            return Positioned(
              top: height * 0.1 * index,
              right: -width * 0.2,
              child: Transform.rotate(
                angle: math.pi / 6,
                child: Container(
                  width: width * 0.7,
                  height: height * 0.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.1),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            );
          }),

          SingleChildScrollView(
            child: Column(
              children: [
                // Enhanced Profile Section
                Container(
                  width: width,
                  height: height * 0.28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor,
                        accentColor.withOpacity(0.8),
                        cardColor,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(width * 0.08),
                      bottomRight: Radius.circular(width * 0.08),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile section - removed back button
                        Row(
                          children: [
                            // Profile image and details side by side
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.04),
                              child: Container(
                                width: width * 0.18,
                                height: width * 0.18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cardColor,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    facultyName[0],
                                    style: TextStyle(
                                      fontSize: width * 0.08,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Name and designation
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    facultyName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * 0.05,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 3,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Text(
                                    designation,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: width * 0.035,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.02,
                                      vertical: width * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.01),
                                    ),
                                    child: Text(
                                      department,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.03,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Info Cards with improved layout
                Transform.translate(
                  offset: Offset(0, -height * 0.02),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: Column(
                      children: [
                        // Make cards more compact by using a grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: width * 0.03,
                          crossAxisSpacing: width * 0.03,
                          childAspectRatio: 2.2,
                          children: [
                            _buildInfoCard(
                              context,
                              title: 'Experience',
                              value: experience,
                              icon: Icons.workspace_premium,
                            ),
                            _buildInfoCard(
                              context,
                              title: 'Department',
                              value: department,
                              icon: Icons.account_balance,
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        _buildQualificationsCard(context),
                        SizedBox(height: height * 0.02),
                        _buildSubjectsCard(context),
                        SizedBox(height: height * 0.02),
                        _buildContactCard(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
        vertical: width * 0.02,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.015),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(width * 0.015),
            ),
            child: Icon(icon, color: accentColor, size: width * 0.035),
          ),
          SizedBox(width: width * 0.015),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: width * 0.028,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.032,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, color: accentColor),
              SizedBox(width: width * 0.02),
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
          SizedBox(height: width * 0.03),
          Wrap(
            spacing: width * 0.02,
            runSpacing: width * 0.02,
            children: subjects
                .map((subject) => _buildSubjectChip(context, subject))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_mail, color: accentColor),
              SizedBox(width: width * 0.02),
              Text(
                'Contact',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.03),
          _buildContactRow(context, Icons.alternate_email, email),
          _buildContactRow(context, Icons.phone_in_talk_outlined, phone),
        ],
      ),
    );
  }

  Widget _buildSubjectChip(BuildContext context, String subject) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: height * 0.008,
      ),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(width * 0.02),
      ),
      child: Text(
        subject,
        style: TextStyle(
          color: textColor,
          fontSize: width * 0.035,
        ),
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String value) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.01),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: width * 0.05),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: width * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationsCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: width * 0.02,
            offset: Offset(0, height * 0.01),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_outlined,
                  color: accentColor, size: width * 0.06),
              SizedBox(width: width * 0.02),
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
          SizedBox(height: height * 0.015),
          _buildQualificationRow(context, 'Ph.D in Computer Science', '2015'),
          _buildQualificationRow(context, 'M.Tech in Computer Science', '2012'),
          _buildQualificationRow(context, 'B.Tech in Computer Science', '2010'),
        ],
      ),
    );
  }

  Widget _buildQualificationRow(
      BuildContext context, String degree, String year) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.02,
              vertical: height * 0.005,
            ),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(width * 0.01),
            ),
            child: Text(
              year,
              style: TextStyle(
                color: accentColor,
                fontSize: width * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              degree,
              style: TextStyle(
                color: textColor,
                fontSize: width * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, String label, String value, IconData icon) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.02),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: width * 0.05),
          SizedBox(width: width * 0.03),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: width * 0.035,
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(BuildContext context, List<String> subjects) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.02),
      child: Wrap(
        spacing: width * 0.02,
        runSpacing: width * 0.02,
        children: subjects
            .map((subject) => _buildSubjectChip(context, subject))
            .toList(),
      ),
    );
  }
}
