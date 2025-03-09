import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final spacing = size.width * 0.1;
    for (var i = 0; i < size.width; i += spacing.toInt()) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble() + spacing, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) => false;
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFF1a237e),
          Color(0xFF0d47a1),
          Color(0xFF311b92),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedCirclesBackground extends StatefulWidget {
  const AnimatedCirclesBackground({super.key});

  @override
  _AnimatedCirclesBackgroundState createState() =>
      _AnimatedCirclesBackgroundState();
}

class _AnimatedCirclesBackgroundState extends State<AnimatedCirclesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CirclesPainter(_controller.value),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CirclesPainter extends CustomPainter {
  final double animation;
  CirclesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final center = Offset(
        size.width / 2 + math.sin(animation * 2 * math.pi + i) * 50,
        size.height / 2 + math.cos(animation * 2 * math.pi + i) * 50,
      );

      canvas.drawCircle(center, 50 + i * 20, paint);
    }
  }

  @override
  bool shouldRepaint(CirclesPainter oldDelegate) => true;
}

class FacultyProfilePage extends StatefulWidget {
  final String facultyName;
  final String department;
  final String designation;
  final String experience;
  final String qualifications;
  final List<String> subjects;
  final String email;
  final String phone;
  final DateTime dateOfBirth;

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
    required this.dateOfBirth,
  });

  @override
  State<FacultyProfilePage> createState() => _FacultyProfilePageState();
}

class _FacultyProfilePageState extends State<FacultyProfilePage> {
  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const cardColor = Color.fromRGBO(34, 39, 42, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);

  // Add stream for qualifications
  late Stream<DocumentSnapshot> _facultyStream;
  String _currentExperience = '';
  List<Map<String, dynamic>> _currentQualifications = [];

  @override
  void initState() {
    super.initState();
    _currentExperience = widget.experience;
    // Set up real-time listener
    _facultyStream = FirebaseFirestore.instance
        .collection('faculty')
        .where('name', isEqualTo: widget.facultyName)
        .snapshots()
        .map((snapshot) => snapshot.docs.first);

    // Initialize qualifications
    _loadQualifications();
  }

  Future<void> _loadQualifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('faculty')
        .where('name', isEqualTo: widget.facultyName)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        _currentQualifications = List<Map<String, dynamic>>.from(
            data['qualificationsList'] ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    tag: 'profile_image',
                    child: CircleAvatar(
                      radius: width * 0.15,
                      backgroundColor: accentColor,
                      child: CircleAvatar(
                        radius: width * 0.14,
                        backgroundColor: cardColor,
                        child: Text(
                          widget.facultyName[0],
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
                    widget.facultyName,
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
                      widget.department,
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
                        _buildStat('Experience', '${widget.experience} Yrs',
                            Icons.timeline),
                        Container(
                            height: height * 0.04,
                            width: 1,
                            color: accentColor.withOpacity(0.3)),
                        _buildStat(
                            'DOB',
                            '${widget.dateOfBirth.day}/${widget.dateOfBirth.month}/${widget.dateOfBirth.year}',
                            Icons.cake),
                        Container(
                            height: height * 0.04,
                            width: 1,
                            color: accentColor.withOpacity(0.3)),
                        _buildStat(
                            'Designation', widget.designation, Icons.work),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),

                  // Other sections
                  _buildQualificationsList(),
                  SizedBox(height: height * 0.02),
                  _buildSubjectsCard(context),
                  SizedBox(height: height * 0.02),
                  _buildContactCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update the _buildStat method to use StreamBuilder for experience
  Widget _buildStat(String title, String value, IconData icon) {
    if (title == 'Experience') {
      return StreamBuilder<DocumentSnapshot>(
        stream: _facultyStream,
        builder: (context, snapshot) {
          final experience = snapshot.hasData 
              ? snapshot.data!.get('experience') ?? _currentExperience
              : _currentExperience;
          
          return _buildStatContent(title, '$experience Yrs', icon);
        },
      );
    }
    return _buildStatContent(title, value, icon);
  }

  // Extract the stat content building logic
  Widget _buildStatContent(String title, String value, IconData icon) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(size.width * 0.02),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor, size: size.width * 0.06),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: size.width * 0.03,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoCard(
          context,
          title: 'Designation',
          value: widget.designation,
          icon: Icons.work,
        ),
        SizedBox(height: 8),
        _buildInfoCard(
          context,
          title: 'Experience',
          value: '${widget.experience} Years',
          icon: Icons.timeline,
        ),
        SizedBox(height: 8),
        _buildInfoCard(
          context,
          title: 'Date of Birth',
          value:
              '${widget.dateOfBirth.day}/${widget.dateOfBirth.month}/${widget.dateOfBirth.year}',
          icon: Icons.cake,
        ),
      ],
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
            children: widget.subjects
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
          _buildContactRow(context, Icons.alternate_email, widget.email),
          _buildContactRow(context, Icons.phone_in_talk_outlined, widget.phone),
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

  Widget _buildQualificationsList() {
    final size = MediaQuery.of(context).size;

    return StreamBuilder<DocumentSnapshot>(
      stream: _facultyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final qualList = (data['qualificationsList'] as List?)
            ?.map((q) => q as Map<String, dynamic>)
            .toList() ?? [];

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(size.width * 0.04),
            border: Border.all(color: accentColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school, color: accentColor),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Qualifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.width * 0.03),
              AnimatedList(
                initialItemCount: qualList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index, animation) {
                  final qual = qualList[index];
                  return SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: Offset(1, 0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutCubic)),
                    ),
                    child: FadeTransition(
                      opacity: animation,
                      child: Container(
                        margin: EdgeInsets.only(bottom: size.width * 0.02),
                        padding: EdgeInsets.all(size.width * 0.03),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accentColor.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                qual['degree'] ?? '',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: size.width * 0.035,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (qual['year']?.isNotEmpty ?? false)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.03,
                                  vertical: size.width * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: accentColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  qual['year'] ?? '',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.width * 0.03,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
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

class ShimmerAvatar extends StatefulWidget {
  final Widget child;
  const ShimmerAvatar({super.key, required this.child});

  @override
  _ShimmerAvatarState createState() => _ShimmerAvatarState();
}

class _ShimmerAvatarState extends State<ShimmerAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + (2.0 * _controller.value), -1.0),
              end: Alignment(1.0 + (2.0 * _controller.value), 1.0),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SlideInText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const SlideInText({super.key, required this.text, required this.style});

  @override
  _SlideInTextState createState() => _SlideInTextState();
}

class _SlideInTextState extends State<SlideInText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 800), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Text(widget.text, style: widget.style),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
