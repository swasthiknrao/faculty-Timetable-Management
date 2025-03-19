import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef FacultySelectCallback = void Function(Map<String, String> faculty);

class FacultyList extends StatefulWidget {
  final FacultySelectCallback onSelect;
  final int periodNumber;

  const FacultyList({
    Key? key,
    required this.onSelect,
    required this.periodNumber,
  }) : super(key: key);

  @override
  State<FacultyList> createState() => _FacultyListState();
}

class _FacultyListState extends State<FacultyList> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, double> _sectionOffsets = {};
  bool _sortByName = true;
  String searchQuery = '';
  Map<String, List<Map<String, String>>> groupedFaculty = {};
  List<String> sortedGroups = [];

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
  }

  void _loadFacultyData() {
    FirebaseFirestore.instance.collection('faculty').get().then((snapshot) {
      if (snapshot.docs.isEmpty) return;

      var facultyList = snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, String>{
          'id': doc.id,
          'name': data['name']?.toString() ?? '',
          'department': data['department']?.toString() ?? '',
        };
      }).toList();

      if (searchQuery.isNotEmpty) {
        facultyList = facultyList.where((faculty) {
          return faculty['name']!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              faculty['department']!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }).toList();
      }

      if (_sortByName) {
        facultyList.sort((a, b) =>
            a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));
      } else {
        facultyList.sort((a, b) => a['department']!
            .toLowerCase()
            .compareTo(b['department']!.toLowerCase()));
      }

      Map<String, List<Map<String, String>>> newGroupedFaculty = {};
      for (var faculty in facultyList) {
        String firstLetter = faculty['name']![0].toUpperCase();
        if (!newGroupedFaculty.containsKey(firstLetter)) {
          newGroupedFaculty[firstLetter] = [];
        }
        newGroupedFaculty[firstLetter]!.add(faculty);
      }

      setState(() {
        groupedFaculty = newGroupedFaculty;
        sortedGroups = newGroupedFaculty.keys.toList()..sort();
      });
    });
  }

  void _scrollToSection(String letter) {
    if (_sectionOffsets.containsKey(letter)) {
      _scrollController.animateTo(
        _sectionOffsets[letter]!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildAlphabetSidebar(List<String> sortedGroups) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(34, 39, 42, 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: sortedGroups.map((letter) {
          return GestureDetector(
            onTap: () => _scrollToSection(letter),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                letter,
                style: const TextStyle(
                  color: Color.fromRGBO(153, 55, 30, 1),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 3) {
          setState(() => _sortByName = true);
        } else if (details.delta.dx < -3) {
          setState(() => _sortByName = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 150.0,
        height: 40,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(34, 39, 42, 1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromRGBO(153, 55, 30, 0.3),
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _sortByName ? 0 : 75.0,
              child: Container(
                width: 75.0,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(153, 55, 30, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Name',
                      style: TextStyle(
                        color: _sortByName
                            ? Colors.white
                            : const Color.fromRGBO(159, 160, 162, 0.7),
                        fontWeight:
                            _sortByName ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Department',
                      style: TextStyle(
                        color: !_sortByName
                            ? Colors.white
                            : const Color.fromRGBO(159, 160, 162, 0.7),
                        fontWeight:
                            !_sortByName ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyItem(Map<String, String> faculty) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSelect(faculty),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(153, 55, 30, 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(153, 55, 30, 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    faculty['name']![0].toUpperCase(),
                    style: const TextStyle(
                      color: Color.fromRGBO(153, 55, 30, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faculty['name']!
                          .split(' ')
                          .map((word) =>
                              word[0].toUpperCase() +
                              word.substring(1).toLowerCase())
                          .join(' '),
                      style: const TextStyle(
                        color: Color.fromRGBO(159, 160, 162, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      faculty['department']!
                          .split(' ')
                          .map((word) =>
                              word[0].toUpperCase() +
                              word.substring(1).toLowerCase())
                          .join(' '),
                      style: const TextStyle(
                        color: Color.fromRGBO(153, 55, 30, 1),
                        fontSize: 14,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildSortButton(),
        ),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount: sortedGroups.length,
                itemBuilder: (context, index) {
                  String letter = sortedGroups[index];
                  var faculties = groupedFaculty[letter]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: const Color.fromRGBO(34, 39, 42, 1),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: Color.fromRGBO(153, 55, 30, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...faculties
                          .map((faculty) => _buildFacultyItem(faculty))
                          .toList(),
                    ],
                  );
                },
              ),
              if (MediaQuery.of(context).size.width > 600)
                Positioned(
                  right: 8,
                  top: 50,
                  bottom: 50,
                  child: _buildAlphabetSidebar(sortedGroups),
                )
              else
                Positioned(
                  right: 8,
                  top: 50,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(34, 39, 42, 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.sort_by_alpha,
                        color: Color.fromRGBO(153, 55, 30, 1),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                const Color.fromRGBO(34, 39, 42, 1),
                            content: _buildAlphabetSidebar(sortedGroups),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
