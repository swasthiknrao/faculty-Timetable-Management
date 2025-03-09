import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faculty.dart';

class FacultyDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _facultyCollection =
      FirebaseFirestore.instance.collection('faculty');

  // Add new faculty
  Future<void> addFaculty(Faculty faculty) async {
    try {
      await _firestore.collection('faculty').add({
        'name': faculty.name,
        'email': faculty.email,
        'phone': faculty.phone,
        'department': faculty.department,
        'username': faculty.username,
        'password': faculty.password,
        'dateOfBirth': faculty.dateOfBirth.toIso8601String(),
        'designation': faculty.designation,
      });
    } catch (e) {
      throw Exception('Failed to add faculty: $e');
    }
  }

  // Get faculty by department
  Stream<List<Faculty>> getFacultyByDepartment(String department) {
    return _facultyCollection
        .where('department', isEqualTo: department)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Faculty.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Update faculty
  Future<void> updateFaculty(Faculty faculty) async {
    try {
      await _firestore.collection('faculty').doc(faculty.id).update({
        'name': faculty.name,
        'email': faculty.email,
        'phone': faculty.phone,
        'department': faculty.department,
        'username': faculty.username,
        'password': faculty.password,
        'dateOfBirth': faculty.dateOfBirth.toIso8601String(),
        'designation': faculty.designation,
      });
    } catch (e) {
      throw Exception('Failed to update faculty: $e');
    }
  }

  // Delete faculty
  Future<void> deleteFaculty(String id) async {
    try {
      await _firestore.collection('faculty').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete faculty: $e');
    }
  }

  Future<void> saveFacultyChanges(
      String department, List<Faculty> facultyList) async {
    try {
      for (var faculty in facultyList) {
        await updateFaculty(faculty);
      }
    } catch (e) {
      throw Exception('Failed to save faculty changes: $e');
    }
  }

  Future<Faculty?> getFacultyByUsername(String username) async {
    try {
      print('Searching for faculty with username: $username');
      final querySnapshot = await _facultyCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      print('Query result docs length: ${querySnapshot.docs.length}');
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        print('Found faculty data: $data');
        return Faculty.fromMap(data, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting faculty by username: $e');
      return null;
    }
  }

  Stream<List<Faculty>> getAllFaculty() {
    return _firestore.collection('faculty').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Faculty.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteDepartment(String departmentId) async {
    try {
      // Delete the department document
      await FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentId)
          .delete();

      // Also delete or update any related faculty documents
      QuerySnapshot facultyDocs = await FirebaseFirestore.instance
          .collection('faculty')
          .where('department', isEqualTo: departmentId)
          .get();

      // Update or delete related faculty documents
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in facultyDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting department: $e');
      throw Exception('Failed to delete department');
    }
  }
}
