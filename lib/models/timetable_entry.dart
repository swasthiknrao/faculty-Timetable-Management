class TimetableEntry {
  final String facultyId;
  final String className;
  final String subject;
  final int dayOfWeek; // 1-6 for Monday-Saturday
  final int period; // 0-7 where 0 is 8:50 and 7 is 3:50
  final bool isLab;
  final int labDuration; // Number of consecutive periods for lab

  TimetableEntry({
    required this.facultyId,
    required this.className,
    required this.subject,
    required this.dayOfWeek,
    required this.period,
    this.isLab = false,
    this.labDuration = 1,
  });

  // Convert to/from JSON for Firebase
  Map<String, dynamic> toJson() => {
        'facultyId': facultyId,
        'className': className,
        'subject': subject,
        'dayOfWeek': dayOfWeek,
        'period': period,
        'isLab': isLab,
        'labDuration': labDuration,
      };

  static TimetableEntry fromJson(Map<String, dynamic> json) => TimetableEntry(
        facultyId: json['facultyId'],
        className: json['className'],
        subject: json['subject'],
        dayOfWeek: json['dayOfWeek'],
        period: json['period'],
        isLab: json['isLab'] ?? false,
        labDuration: json['labDuration'] ?? 1,
      );

  // Helper method to validate period rules
  bool isValidPeriod() {
    // Regular periods 1-6
    if (period >= 1 && period <= 6) return true;

    // Period 0 only if specified
    if (period == 0) return true;

    // Period 7 only for labs
    if (period == 7 && isLab) return true;

    // Saturday only periods 0-3
    if (dayOfWeek == 6 && period > 3) return false;

    return false;
  }
}
