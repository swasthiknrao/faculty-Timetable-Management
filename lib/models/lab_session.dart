class LabSession {
  final List<String> facultyNames;
  final List<String> subjects;

  LabSession({
    required this.facultyNames,
    required this.subjects,
  });

  Map<String, dynamic> toJson() {
    return {
      'facultyNames': facultyNames,
      'subjects': subjects,
    };
  }

  factory LabSession.fromJson(Map<String, dynamic> json) {
    return LabSession(
      facultyNames: List<String>.from(json['facultyNames'] ?? []),
      subjects: List<String>.from(json['subjects'] ?? []),
    );
  }
} 