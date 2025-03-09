import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all departments
  Stream<List<String>> getDepartments() {
    return _firestore.collection('departments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Add new department
  Future<void> addDepartment(String departmentName) async {
    try {
      await _firestore.collection('departments').doc(departmentName).set({
        'name': departmentName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add department: $e');
    }
  }

  // Delete department
  Future<void> deleteDepartment(String departmentName) async {
    try {
      await _firestore.collection('departments').doc(departmentName).delete();
    } catch (e) {
      throw Exception('Failed to delete department: $e');
    }
  }

  // New method to remove all departments
  Future<void> removeAllDepartments() async {
    try {
      // Get all department documents
      QuerySnapshot snapshot = await _firestore.collection('departments').get();

      // Delete each department document
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to remove all departments: $e');
    }
  }

  Future<void> saveDepartment(String department) async {
    try {
      await _firestore.collection('departments').doc(department).set({
        'name': department,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save department: $e');
    }
  }
}
