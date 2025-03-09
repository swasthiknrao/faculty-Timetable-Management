import 'package:flutter/material.dart';
import 'admin/faculty_management.dart';
import 'login_page.dart';
import 'utils/slide_route.dart';
import 'admin/class_selection.dart';
import 'admin/timetable_viewer.dart';
import 'admin/settings_page.dart';
import 'admin/faculty_catalog.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Define the color scheme
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
            // ... other periods
          }
          // ... other days
        }
        // ... other sections
      }
      // ... other years
    }
    // ... other courses
  };

  // Add this sample faculty data structure
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

  // Update this field to match faculty_management.dart departments
  final List<String> departments = [
    'Computer Applications Dept.',
    'Business Administration Dept.',
    'Commerce Dept.',
    'Science Dept.',
    'Language Dept.',
  ];

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
      title: const Text(
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
            MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            ),
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
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your institution',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              _buildManagementSection(),
              const SizedBox(height: 24),
              _buildQuickStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Management',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context: context,
              icon: Icons.people,
              title: 'Faculty',
              subtitle: 'Manage faculty members',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FacultyManagement(),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.calendar_today,
              title: 'Timetable',
              subtitle: 'Manage class schedules',
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(
                    page: const ClassSelection(),
                    direction: AxisDirection.left,
                  ),
                );
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.schedule,
              title: 'View Schedule',
              subtitle: 'Check timetables',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimetableViewer(
                      timetableData: timetableManagementData,
                    ),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.menu_book,
              title: 'Faculty Catalog',
              subtitle: 'View faculty by department',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FacultyCatalog(
                      facultyData: facultyData,
                      departments: departments,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outline,
                title: 'Total Faculty',
                value: '${facultyData.length}',
              ),
            ),
            const SizedBox(width: 16),
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
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: accentColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
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
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 24, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
