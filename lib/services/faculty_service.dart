import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> updateFacultyDetails(
      String facultyName, Map<String, dynamic> data) async {
    try {
      final querySnapshot = await _firestore
          .collection('faculty')
          .where('name', isEqualTo: facultyName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Faculty not found');
      }

      await querySnapshot.docs.first.reference.update(data);
    } catch (e) {
      throw Exception('Failed to update faculty details: $e');
    }
  }

  static Stream<DocumentSnapshot> getFacultyStream(String facultyName) {
    return _firestore
        .collection('faculty')
        .where('name', isEqualTo: facultyName)
        .snapshots()
        .map((snapshot) => snapshot.docs.first);
  }

  static Future<Map<String, dynamic>> getFacultyDetails(
      String facultyName) async {
    try {
      final querySnapshot = await _firestore
          .collection('faculty')
          .where('name', isEqualTo: facultyName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Faculty not found');
      }

      return querySnapshot.docs.first.data();
    } catch (e) {
      throw Exception('Failed to get faculty details: $e');
    }
  }

  static Future<String?> getFacultyId(String facultyName) async {
    try {
      final querySnapshot = await _firestore
          .collection('faculty')
          .where('name', isEqualTo: facultyName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return querySnapshot.docs.first.id;
    } catch (e) {
      throw Exception('Failed to get faculty ID: $e');
    }
  }
}
