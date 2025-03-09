import 'package:flutter/material.dart';

class FacultyDetailPage extends StatelessWidget {
  final Map<String, dynamic> faculty;

  const FacultyDetailPage({
    super.key,
    required this.faculty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 29, 32, 1),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildContactCard(),
                  const SizedBox(height: 16),
                  _buildQualificationCard(),
                  const SizedBox(height: 16),
                  _buildSubjectsCard(),
                  if (faculty['schedule'] != null) ...[
                    const SizedBox(height: 16),
                    _buildScheduleCard(),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color.fromRGBO(32, 38, 42, 1),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2C3E50), // Dark blue-gray
                Color(0xFF3498DB), // Bright blue
                Color(0xFF2980B9), // Darker blue
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3498DB).withOpacity(0.5),
                      const Color(0xFF2980B9).withOpacity(0.5),
                    ],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromRGBO(24, 29, 32, 1),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFF3498DB),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                faculty['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                    ),
                  ],
                ),
              ),
              Text(
                faculty['designation'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(32, 38, 42, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContactTile(
            icon: Icons.business,
            title: 'Department',
            subtitle: faculty['department'],
          ),
          _buildDivider(),
          _buildContactTile(
            icon: Icons.email,
            title: 'Email',
            subtitle: faculty['email'],
          ),
          _buildDivider(),
          _buildContactTile(
            icon: Icons.phone,
            title: 'Phone',
            subtitle: faculty['phone'],
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(32, 38, 42, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.school,
                color: Color.fromRGBO(153, 55, 30, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Qualifications',
                style: TextStyle(
                  color: Color.fromRGBO(153, 55, 30, 1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            faculty['qualification'],
            style: const TextStyle(
              color: Color.fromRGBO(159, 160, 162, 1),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${faculty['experience']} of Experience',
            style: const TextStyle(
              color: Color.fromRGBO(159, 160, 162, 1),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(32, 38, 42, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.book,
                color: Color.fromRGBO(153, 55, 30, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Subjects',
                style: TextStyle(
                  color: Color.fromRGBO(153, 55, 30, 1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (faculty['subjects'] as List).map((subject) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromRGBO(153, 55, 30, 1),
                  ),
                ),
                child: Text(
                  subject,
                  style: const TextStyle(
                    color: Color.fromRGBO(159, 160, 162, 1),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(32, 38, 42, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.schedule,
                color: Color.fromRGBO(153, 55, 30, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Schedule',
                style: TextStyle(
                  color: Color.fromRGBO(153, 55, 30, 1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(24, 29, 32, 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                // Header Row
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color:
                        const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.1),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Day',
                          style: TextStyle(
                            color: Color.fromRGBO(153, 55, 30, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Time',
                          style: TextStyle(
                            color: Color.fromRGBO(153, 55, 30, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Subject',
                          style: TextStyle(
                            color: Color.fromRGBO(153, 55, 30, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Class',
                          style: TextStyle(
                            color: Color.fromRGBO(153, 55, 30, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Schedule Rows
                ...List.generate(
                  (faculty['schedule'] as List).length,
                  (index) {
                    final schedule = faculty['schedule'][index];
                    final isLast =
                        index == (faculty['schedule'] as List).length - 1;
                    return Column(
                      children: [
                        if (index > 0)
                          Container(
                            height: 1,
                            color: const Color.fromRGBO(153, 55, 30, 1)
                                .withOpacity(0.1),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(153, 55, 30, 1)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    schedule['day'],
                                    style: const TextStyle(
                                      color: Color.fromRGBO(153, 55, 30, 1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  schedule['time'],
                                  style: const TextStyle(
                                    color: Color.fromRGBO(159, 160, 162, 1),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  schedule['subject'],
                                  style: const TextStyle(
                                    color: Color.fromRGBO(159, 160, 162, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  schedule['class'],
                                  style: const TextStyle(
                                    color: Color.fromRGBO(159, 160, 162, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color.fromRGBO(153, 55, 30, 1),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color.fromRGBO(159, 160, 162, 1),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: const Color.fromRGBO(159, 160, 162, 1).withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.1),
    );
  }
}
