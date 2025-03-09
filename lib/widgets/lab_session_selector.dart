import 'package:flutter/material.dart';
import '../models/lab_session.dart';

class LabSessionSelector extends StatefulWidget {
  final LabSession? initialValue;
  final Function(LabSession) onSave;

  const LabSessionSelector({
    Key? key,
    this.initialValue,
    required this.onSave,
  }) : super(key: key);

  @override
  State<LabSessionSelector> createState() => _LabSessionSelectorState();
}

class _LabSessionSelectorState extends State<LabSessionSelector> {
  late List<String> facultyNames;
  late List<String> subjects;
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    facultyNames = widget.initialValue?.facultyNames ?? [];
    subjects = widget.initialValue?.subjects ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lab Session Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Faculty Members',
              items: facultyNames,
              controller: _facultyController,
              onAdd: () {
                if (_facultyController.text.isNotEmpty) {
                  setState(() {
                    facultyNames.add(_facultyController.text);
                    _facultyController.clear();
                  });
                }
              },
              onDelete: (index) {
                setState(() {
                  facultyNames.removeAt(index);
                });
              },
              hintText: 'Enter faculty name',
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Subjects',
              items: subjects,
              controller: _subjectController,
              onAdd: () {
                if (_subjectController.text.isNotEmpty) {
                  setState(() {
                    subjects.add(_subjectController.text);
                    _subjectController.clear();
                  });
                }
              },
              onDelete: (index) {
                setState(() {
                  subjects.removeAt(index);
                });
              },
              hintText: 'Enter subject name',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(LabSession(
                      facultyNames: facultyNames,
                      subjects: subjects,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required Function(int) onDelete,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items.asMap().entries.map((entry) {
            return Chip(
              label: Text(entry.value),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => onDelete(entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }
} 