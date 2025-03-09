import 'package:flutter/foundation.dart';

class LabHoursProvider extends ChangeNotifier {
  // Define lab hour configurations
  final List<List<int>> labHourConfigurations = [
    [0, 1, 2, 3], // First lab hour block (1st to 4th hour)
    [4, 5, 6, 7], // Second lab hour block (5th to 8th hour)
  ];

  // Method to check if an hour is part of a lab block
  bool isLabHour(int hour) {
    return labHourConfigurations.any((block) => block.contains(hour));
  }

  // Method to get the complete lab block for a given hour
  List<int> getLabBlock(int hour) {
    return labHourConfigurations.firstWhere(
      (block) => block.contains(hour),
      orElse: () => [],
    );
  }
}
