import 'package:flutter/material.dart';
import 'faculty_list.dart';

class FacultySelectionDialog extends StatelessWidget {
  final Function(Map<String, String>) onSelect;
  final int periodNumber;

  const FacultySelectionDialog({
    Key? key,
    required this.onSelect,
    required this.periodNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color.fromRGBO(153, 55, 30, 0.3),
        ),
      ),
      child: FacultyList(
        onSelect: onSelect,
        periodNumber: periodNumber,
      ),
    );
  }
}

void showFacultySelectionDialog(BuildContext context,
    Function(Map<String, String>) onSelect, int periodNumber) {
  showDialog(
    context: context,
    builder: (context) => FacultySelectionDialog(
      onSelect: onSelect,
      periodNumber: periodNumber,
    ),
  );
}
