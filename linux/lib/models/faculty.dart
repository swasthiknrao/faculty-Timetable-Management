class Faculty {
  final String name;
  final String department;
  final String email;
  final String phone;
  final String username;
  final String password;
  final DateTime dateOfBirth;
  String designation;

  Faculty({
    required this.name,
    required this.department,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
    required this.dateOfBirth,
    this.designation = 'Assistant Professor',
  });
}
