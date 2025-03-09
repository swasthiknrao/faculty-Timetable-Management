import 'package:flutter/material.dart';
import 'timetable_management.dart';
import '../utils/slide_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassSelection extends StatefulWidget {
  const ClassSelection({super.key});

  @override
  State<ClassSelection> createState() => _ClassSelectionState();
}

class _ClassSelectionState extends State<ClassSelection> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> courses = [];
  String? selectedCourse;
  String? selectedYear;
  String? selectedSection;

  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Add stream subscription
  late Stream<QuerySnapshot> _coursesStream;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Setup real-time listener
    _coursesStream = FirebaseFirestore.instance
        .collection('courses')
        .orderBy('timestamp', descending: true)
        .snapshots();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Add this helper method for Roman numeral conversion
  String _toRoman(String number) {
    final Map<int, String> romanNumerals = {
      1: 'I',
      2: 'II',
      3: 'III',
      4: 'IV',
      5: 'V',
      6: 'VI',
      7: 'VII',
      8: 'VIII',
      9: 'IX',
      10: 'X',
    };
    
    // Remove any non-numeric characters and convert to int
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    final num = int.tryParse(cleanNumber);
    if (num != null && num > 0 && num <= 10) {
      return romanNumerals[num] ?? number;
    }
    return number;
  }

  void _addNewCourse() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(
              Icons.school,
              size: 48,
              color: Color.fromRGBO(153, 55, 30, 1),
            ),
            SizedBox(height: 16),
            Text(
              'Create New Course',
              style: TextStyle(
                color: Color.fromRGBO(159, 160, 162, 1),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                _buildInputField(
                controller: _courseNameController,
                  label: 'Course Name',
                  icon: Icons.book,
              ),
              const SizedBox(height: 16),
                _buildInputField(
                controller: _yearController,
                  label: 'Years (comma separated)',
                  icon: Icons.calendar_today,
                  hint: 'e.g., 1, 2, 3',
                  inputValidator: (value) {
                    return RegExp(r'^[0-9,\s]*$').hasMatch(value);
                  },
                  errorText: 'Please enter only numbers',
              ),
              const SizedBox(height: 16),
                _buildInputField(
                controller: _sectionController,
                  label: 'Sections (comma separated)',
                  icon: Icons.group,
                  hint: 'e.g., A, B, C',
                  inputValidator: (value) {
                    return RegExp(r'^[A-Za-z,\s]*$').hasMatch(value);
                  },
                  errorText: 'Please enter only letters',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Color.fromRGBO(159, 160, 162, 1),
            ),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(153, 55, 30, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
            onPressed: () async {
              if (_courseNameController.text.isNotEmpty &&
                  _yearController.text.isNotEmpty &&
                  _sectionController.text.isNotEmpty) {
                try {
                  final courseName = _courseNameController.text.trim();
                    // Convert years to Roman numerals
                    final newYears = _yearController.text
                      .split(',')
                        .map((e) => _toRoman(e.trim()))
                      .where((e) => e.isNotEmpty)
                      .toList();
                    // Convert sections to uppercase
                    final newSections = _sectionController.text
                      .split(',')
                        .map((e) => e.trim().toUpperCase())
                      .where((e) => e.isNotEmpty)
                      .toList();

                    // Get existing document reference
                    final docRef = FirebaseFirestore.instance
                      .collection('courses')
                        .doc(courseName);

                    // Get existing document
                    final docSnapshot = await docRef.get();

                    if (docSnapshot.exists) {
                      // If document exists, merge new years and sections
                      final existingData = docSnapshot.data() as Map<String, dynamic>;
                      final existingYears = List<String>.from(existingData['years'] ?? []);
                      final existingSections = List<String>.from(existingData['sections'] ?? []);

                      // Merge and remove duplicates
                      final updatedYears = {...existingYears, ...newYears}.toList();
                      final updatedSections = {...existingSections, ...newSections}.toList();

                      await docRef.update({
                        'years': updatedYears,
                        'sections': updatedSections,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    } else {
                      // If document doesn't exist, create new
                      await docRef.set({
                      'name': courseName,
                        'years': newYears,
                        'sections': newSections,
                        'timestamp': FieldValue.serverTimestamp(),
                    });
                    }

                  _courseNameController.clear();
                  _yearController.clear();
                  _sectionController.clear();

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Course updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                    debugPrint('Error updating course: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error updating course: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Create Course',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool Function(String)? inputValidator,
    String? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 29, 32, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(153, 55, 30, 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
        onChanged: (value) {
          if (inputValidator != null) {
            if (!inputValidator(value)) {
              controller.text = value.replaceAll(
                RegExp(label.contains('Years') ? r'[^0-9,\s]' : r'[^A-Za-z,\s]'),
                '',
              );
            }
          }
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          hintText: hint,
          errorText: controller.text.isNotEmpty && inputValidator != null && 
                    !inputValidator(controller.text) ? errorText : null,
          hintStyle: TextStyle(
            color: const Color.fromRGBO(159, 160, 162, 0.5),
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            color: Color.fromRGBO(153, 55, 30, 1),
          ),
          icon: Icon(
            icon,
            color: const Color.fromRGBO(153, 55, 30, 1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        elevation: 0,
        title: const Text(
          'Course Selection',
          style: TextStyle(
            color: Color.fromRGBO(159, 160, 162, 1),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _coursesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(153, 55, 30, 1),
              ),
            );
          }

          courses = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'name': data['name'] as String,
              'years': List<String>.from(data['years'] ?? []),
              'sections': List<String>.from(data['sections'] ?? []),
            };
          }).toList();

          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: const Color.fromRGBO(153, 55, 30, 1).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No courses yet',
                    style: TextStyle(
                      color: Color.fromRGBO(159, 160, 162, 1),
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first course by tapping the + button',
                    style: TextStyle(
                      color: Color.fromRGBO(159, 160, 162, 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      (index / courses.length) * 0.5,
                      1.0,
                      curve: Curves.easeOutBack,
                    ),
                  )),
                  child: _buildCourseCard(courses[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCourse,
        backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final isSelected = selectedCourse == course['name'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color.fromRGBO(45, 50, 54, 1),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
        child: InkWell(
        onTap: () => _showCourseDetails(course),
        borderRadius: BorderRadius.circular(12),
          child: Padding(
          padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.school,
                    size: 32,
                    color: const Color.fromRGBO(153, 55, 30, 1),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        course['name'],
                      style: const TextStyle(
                        color: Color.fromRGBO(159, 160, 162, 1),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color.fromRGBO(159, 160, 162, 1),
                    ),
                    color: const Color.fromRGBO(34, 39, 42, 1),
                    onSelected: (value) => _handleMenuAction(value, course),
                    itemBuilder: (context) => [
                      _buildPopupMenuItem('rename_course', 'Rename Course', Icons.edit),
                      _buildPopupMenuItem('edit_years', 'Edit Years', Icons.calendar_today),
                      _buildPopupMenuItem('edit_sections', 'Edit Sections', Icons.group),
                      const PopupMenuDivider(),
                      _buildPopupMenuItem('delete_course', 'Delete Course', Icons.delete, color: Colors.red),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    '${course['years'].length} Years',
                    Icons.calendar_today,
                  ),
                  _buildInfoChip(
                    '${course['sections'].length} Sections',
                    Icons.group,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String text, IconData icon, {Color? color}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
      children: [
          Icon(icon, color: color ?? const Color.fromRGBO(153, 55, 30, 1), size: 20),
          const SizedBox(width: 12),
        Text(
            text,
            style: TextStyle(
              color: color ?? const Color.fromRGBO(159, 160, 162, 1),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> course) {
    switch (action) {
      case 'rename_course':
        _showRenameDialog(course);
        break;
      case 'edit_years':
        _showEditYearsDialog(course);
        break;
      case 'edit_sections':
        _showEditSectionsDialog(course);
        break;
      case 'delete_course':
        _showDeleteConfirmation(course);
        break;
    }
  }

  void _showRenameDialog(Map<String, dynamic> course) {
    final TextEditingController controller = TextEditingController(text: course['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Text(
          'Rename Course',
          style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
          decoration: const InputDecoration(
            labelText: 'Course Name',
            labelStyle: TextStyle(color: Color.fromRGBO(153, 55, 30, 1)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Color.fromRGBO(159, 160, 162, 1),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != course['name']) {
                try {
                  final batch = FirebaseFirestore.instance.batch();
                  final oldDoc = FirebaseFirestore.instance.collection('courses').doc(course['name']);
                  final newDoc = FirebaseFirestore.instance.collection('courses').doc(newName);
                  
                  final data = (await oldDoc.get()).data();
                  if (data != null) {
                    data['name'] = newName;
                    batch.set(newDoc, data);
                    batch.delete(oldDoc);
                    await batch.commit();
                  }
                  
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  debugPrint('Error renaming course: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Rename',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditYearsDialog(Map<String, dynamic> course) {
    final years = List<String>.from(course['years']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Text(
          'Edit Years',
          style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: years.map((year) => ListTile(
              title: Text(
                year,
                style: const TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  years.remove(year);
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(course['name'])
                      .update({'years': years});
                  if (mounted) Navigator.pop(context);
                },
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Color.fromRGBO(159, 160, 162, 1),
            ),
            child: const Text(
              'Close',
              style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSectionsDialog(Map<String, dynamic> course) {
    final sections = List<String>.from(course['sections']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Text(
          'Edit Sections',
          style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sections.map((section) => ListTile(
              title: Text(
                section,
                style: const TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  sections.remove(section);
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(course['name'])
                      .update({'sections': sections});
                  if (mounted) Navigator.pop(context);
                },
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Color.fromRGBO(159, 160, 162, 1),
            ),
            child: const Text(
              'Close',
              style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 39, 42, 1),
        title: const Text(
          'Delete Course',
          style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
        ),
        content: Text(
          'Are you sure you want to delete ${course['name']}?',
          style: const TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Color.fromRGBO(159, 160, 162, 1),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromRGBO(159, 160, 162, 1)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Close the dialog first
                Navigator.pop(context);
                
                // Delete the document
                await FirebaseFirestore.instance
                    .collection('courses')
                    .doc(course['name'])
                    .delete();

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Course deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error deleting course: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting course: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(34, 39, 42, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color.fromRGBO(153, 55, 30, 1),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color.fromRGBO(159, 160, 162, 1),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(34, 39, 42, 1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              course['name'],
              style: const TextStyle(
                color: Color.fromRGBO(159, 160, 162, 1),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSelectionGrid('Year', course['years']),
                    const SizedBox(height: 16),
                    _buildSelectionGrid('Section', course['sections']),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
                child: ElevatedButton(
          onPressed: () {
                    if (selectedYear != null && selectedSection != null) {
                      Navigator.pop(context);
              Navigator.push(
                context,
                SlidePageRoute(
                  page: TimetableManagement(
                            course: course['name'],
                    year: selectedYear!,
                    section: selectedSection!,
                  ),
                  direction: AxisDirection.left,
                ),
              );
            }
          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(153, 55, 30, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    minimumSize: Size(MediaQuery.of(context).size.width - 40, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Edit Timetable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionGrid(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(153, 55, 30, 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  title == 'Year' ? Icons.calendar_today : Icons.group,
                  size: 16,
                  color: const Color.fromRGBO(153, 55, 30, 1),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color.fromRGBO(159, 160, 162, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((item) {
              final isSelected = (title == 'Year' && selectedYear == item) ||
                  (title == 'Section' && selectedSection == item);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      if (title == 'Year') {
                        selectedYear = selectedYear == item ? null : item;
                        selectedSection = null;
                      } else {
                        selectedSection = selectedSection == item ? null : item;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 28 : 24,
                      vertical: isSelected ? 14 : 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                Color.fromRGBO(153, 55, 30, 1),
                                Color.fromRGBO(203, 75, 40, 1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected 
                          ? null 
                          : const Color.fromRGBO(45, 50, 54, 1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.transparent
                            : const Color.fromRGBO(153, 55, 30, 0.3),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color.fromRGBO(153, 55, 30, 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white
                            : const Color.fromRGBO(159, 160, 162, 1),
                        fontSize: isSelected ? 16 : 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      child: Text(
                        title == 'Year' ? _toRoman(item) : item.toString().toUpperCase(),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF993722),
          Color(0xFFFF6B4A),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    for (var i = 0; i < 5; i++) {
      path.moveTo(0, size.height * (0.2 + (i * 0.2)));
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * (0.2 + (i * 0.2) + (i.isEven ? 0.1 : -0.1)),
        size.width,
        size.height * (0.2 + (i * 0.2)),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
