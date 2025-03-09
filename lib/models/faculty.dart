import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty {
  final String? id;
  final String name;
  final String department;
  final String designation;
  final String email;
  final String phone;
  final String username;
  final String password;
  final DateTime dateOfBirth;
  final String experience;
  final String qualifications;
  final List<String> subjects;
  final List<Map<String, dynamic>>? schedule;

  Faculty({
    this.id,
    required this.name,
    required this.department,
    required this.designation,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
    required this.dateOfBirth,
    required this.experience,
    required this.qualifications,
    required this.subjects,
    this.schedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'designation': designation,
      'email': email,
      'phone': phone,
      'username': username,
      'password': password,
      'dateOfBirth': dateOfBirth,
      'experience': experience,
      'qualifications': qualifications,
      'subjects': subjects,
      'schedule': schedule,
    };
  }

  factory Faculty.fromMap(Map<String, dynamic> map, String id) {
    final dateData = map['dateOfBirth'];
    final DateTime date = dateData is Timestamp
        ? dateData.toDate()
        : dateData is String
            ? DateTime.parse(dateData)
            : DateTime.now();

    return Faculty(
      id: id,
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      designation: map['designation'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      dateOfBirth: date,
      experience: map['experience'] ?? '',
      qualifications: map['qualifications'] ?? '',
      subjects: List<String>.from(map['subjects'] ?? []),
      schedule: map['schedule'] != null
          ? List<Map<String, dynamic>>.from(map['schedule'])
          : null,
    );
  }

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'],
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      experience: json['experience'] ?? '',
      qualifications: json['qualifications'] ?? '',
      subjects: List<String>.from(json['subjects'] ?? []),
      schedule: json['schedule'] != null
          ? List<Map<String, dynamic>>.from(json['schedule'])
          : null,
    );
  }
}
