import 'package:flutter/material.dart';
import 'admin/faculty_management.dart';
import 'login_page.dart';
import 'utils/slide_route.dart';
import 'admin/class_selection.dart';
import 'admin/timetable_viewer.dart';
import 'admin/settings_page.dart';
import 'admin/faculty_catalog.dart';
import 'package:flutter/services.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const backgroundColor = Color.fromRGBO(24, 29, 32, 1);
  static const textColor = Color.fromRGBO(159, 160, 162, 1);
  static const accentColor = Color.fromRGBO(153, 55, 30, 1);
  static const cardColor = Color.fromRGBO(32, 38, 42, 1);

  final Map<String, dynamic> timetableManagementData = {
    'BCA': {
      '1st Year': {
        'A': {
          'MON': {
            '1': {
              'subject': 'Programming Lab',
              'isLab': true,
              'duration': 2,
              'faculty': ['John Doe', 'Jane Smith']
            },
            '2': {
              'subject': 'Programming Lab',
              'isLab': true,
              'duration': 2,
              'faculty': ['John Doe', 'Jane Smith']
            },
            '3': {
              'subject': 'Mathematics',
              'faculty': ['Alice Johnson']
            }
          }
        }
      }
    }
  };

  final List<Map<String, dynamic>> facultyData = [
    {
      'name': 'Dr. Rajesh Kumar',
      'department': 'Computer Applications Dept.',
      'designation': 'Associate Professor',
      'email': 'rajesh.kumar@college.edu',
      'phone': '9876543210',
      'qualification': 'Ph.D in Computer Science',
      'experience': '12 years',
      'subjects': [
        'Java Programming',
        'Database Management',
        'Web Development'
      ],
      'schedule': [
        {
          'day': 'MON',
          'time': '9:45 - 10:35',
          'class': 'BCA 2nd Year A',
          'subject': 'Java Programming'
        },
        {
          'day': 'MON',
          'time': '11:35 - 12:25',
          'class': 'BCA 3rd Year B',
          'subject': 'Web Development'
        },
        {
          'day': 'TUE',
          'time': '10:40 - 11:30',
          'class': 'BCA 1st Year A',
          'subject': 'Database Management'
        }
      ]
    },
    {
      'name': 'Prof. Priya Sharma',
      'department': 'Language Dept.',
      'designation': 'Assistant Professor',
      'email': 'priya.sharma@college.edu',
      'phone': '9876543211',
      'qualification': 'M.A. in English Literature, NET Qualified',
      'experience': '8 years',
      'subjects': [
        'Business Communication',
        'English Literature',
        'Technical Writing'
      ],
      'schedule': [
        {
          'day': 'MON',
          'time': '9:45 - 10:35',
          'class': 'BBA 1st Year A',
          'subject': 'Business Communication'
        },
        {
          'day': 'WED',
          'time': '11:35 - 12:25',
          'class': 'BCA 1st Year B',
          'subject': 'Technical Writing'
        }
      ]
    },
    {
      'name': 'Dr. Amit Verma',
      'department': 'Business Administration Dept.',
      'designation': 'Professor & HOD',
      'email': 'amit.verma@college.edu',
      'phone': '9876543212',
      'qualification': 'Ph.D in Management, MBA',
      'experience': '15 years',
      'subjects': [
        'Marketing Management',
        'Business Strategy',
        'Entrepreneurship'
      ],
      'schedule': [
        {
          'day': 'TUE',
          'time': '10:40 - 11:30',
          'class': 'BBA 3rd Year A',
          'subject': 'Business Strategy'
        },
        {
          'day': 'THU',
          'time': '2:00 - 2:50',
          'class': 'BBA 2nd Year B',
          'subject': 'Marketing Management'
        }
      ]
    },
    {
      'name': 'Dr. Meera Patel',
      'department': 'Science Dept.',
      'designation': 'Associate Professor',
      'email': 'meera.patel@college.edu',
      'phone': '9876543213',
      'qualification': 'Ph.D in Physics, M.Sc Physics',
      'experience': '10 years',
      'subjects': ['Physics', 'Mathematics', 'Electronics'],
      'schedule': [
        {
          'day': 'MON',
          'time': '10:40 - 11:30',
          'class': 'BSc 2nd Year A',
          'subject': 'Physics Lab',
          'isLab': true,
          'duration': 2
        },
        {
          'day': 'WED',
          'time': '9:45 - 10:35',
          'class': 'BSc 1st Year A',
          'subject': 'Physics'
        }
      ]
    },
    {
      'name': 'Prof. Suresh Reddy',
      'department': 'Commerce Dept.',
      'designation': 'Assistant Professor',
      'email': 'suresh.reddy@college.edu',
      'phone': '9876543214',
      'qualification': 'M.Com, CA, NET Qualified',
      'experience': '7 years',
      'subjects': ['Accounting', 'Taxation', 'Corporate Law'],
      'schedule': [
        {
          'day': 'TUE',
          'time': '11:35 - 12:25',
          'class': 'BCom 2nd Year A',
          'subject': 'Taxation'
        },
        {
          'day': 'FRI',
          'time': '10:40 - 11:30',
          'class': 'BCom 3rd Year B',
          'subject': 'Corporate Law'
        }
      ]
    }
  ];

  final List<String> departments = [
    'Computer Applications Dept.',
    'Business Administration Dept.',
    'Commerce Dept.',
    'Science Dept.',
    'Language Dept.',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context),
      body: _buildDashboard(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Admin Dashboard',
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: accentColor),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: accentColor),
          onPressed: () => Navigator.of(context).pushReplacement(
            SlidePageRoute(
                page: const LoginPage(), direction: AxisDirection.right),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: textColor,
                        fontSize: screenHeight * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Manage your institution',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: screenHeight * 0.02,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _buildManagementSection(),
                    SizedBox(height: screenHeight * 0.03),
                    _buildQuickStats(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManagementSection() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Management',
          style: TextStyle(
            color: textColor,
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: screenWidth * 0.04,
            mainAxisSpacing: screenWidth * 0.04,
            childAspectRatio: 1.0,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final menuItems = [
              {
                'icon': Icons.group_add_rounded,
                'title': 'Faculty',
                'subtitle': 'Manage faculty members',
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FacultyManagement()),
                    ),
              },
              {
                'icon': Icons.calendar_month_outlined,
                'title': 'Timetable',
                'subtitle': 'Manage class schedules',
                'onTap': () => Navigator.push(
                      context,
                      SlidePageRoute(
                          page: const ClassSelection(),
                          direction: AxisDirection.left),
                    ),
              },
              {
                'icon': Icons.event_note_rounded,
                'title': 'View Schedule',
                'subtitle': 'Check timetables',
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimetableViewer(
                            timetableData: timetableManagementData),
                      ),
                    ),
              },
              {
                'icon': Icons.library_books_rounded,
                'title': 'Faculty Catalog',
                'subtitle': 'View faculty by department',
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacultyCatalog(
                          facultyData: facultyData.map((data) => data).toList(),
                          departments: departments,
                        ),
                      ),
                    ),
              }
            ];

            final item = menuItems[index];
            return _buildMenuCard(
              context: context,
              icon: item['icon'] as IconData,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              onTap: item['onTap'] as VoidCallback,
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Quick Stats',
          style: TextStyle(
            color: textColor,
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outline,
                title: 'Total Faculty',
                value: '${facultyData.length}',
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: _buildStatCard(
                icon: Icons.category_outlined,
                title: 'Departments',
                value: '${departments.length}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        side: BorderSide(color: accentColor.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Icon(icon,
                        size: screenWidth * 0.07, color: accentColor),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: screenHeight * 0.018,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Flexible(
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: screenHeight * 0.014,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        side: BorderSide(color: accentColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child:
                      Icon(icon, size: screenWidth * 0.06, color: accentColor),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: screenHeight * 0.018,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
