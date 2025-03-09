import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/timetable_entry.dart';
import 'package:flutter/foundation.dart';

class TimetableDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get collection reference for a specific class timetable
  CollectionReference _getTimetableRef(
      String course, String year, String section) {
    return _firestore
        .collection('timetables')
        .doc('${course}_${year}_$section')
        .collection('entries');
  }

  // Add or update a timetable entry
  Future<void> addTimetableEntry(
    String course,
    String year,
    String section,
    TimetableEntry entry,
  ) async {
    try {
      final timetableRef = _getTimetableRef(course, year, section);

      // Create a unique ID for each entry based on day and period
      final String entryId = '${entry.dayOfWeek}_${entry.period}';

      await timetableRef.doc(entryId).set(entry.toJson());

      // Also ensure the course exists in the courses collection
      await _firestore.collection('courses').doc(course).set({
        'name': course,
        'years': FieldValue.arrayUnion([year]),
        'sections': FieldValue.arrayUnion([section]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error adding timetable entry: $e');
      rethrow;
    }
  }

  // Get all entries for a specific class timetable
  Stream<List<TimetableEntry>> getTimetableEntries(
    String course,
    String year,
    String section,
  ) {
    final timetableRef = _getTimetableRef(course, year, section);

    return timetableRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              TimetableEntry.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Delete a timetable entry
  Future<void> deleteTimetableEntry(
    String course,
    String year,
    String section,
    int dayOfWeek,
    int period,
  ) async {
    try {
      final timetableRef = _getTimetableRef(course, year, section);
      final String entryId = '${dayOfWeek}_$period';
      await timetableRef.doc(entryId).delete();
    } catch (e) {
      debugPrint('Error deleting timetable entry: $e');
      rethrow;
    }
  }
}
