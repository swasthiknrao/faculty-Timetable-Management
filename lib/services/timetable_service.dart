import '../models/timetable_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local storage for timetable data
  final Map<String, Map<String, Map<String, Map<String, dynamic>>>>
      _timetableData = {};

  // Add a new timetable entry
  Future<void> addTimetableEntry(TimetableEntry entry) async {
    if (!entry.isValidPeriod()) {
      throw Exception('Invalid period for given day/lab configuration');
    }

    // Create nested structure if it doesn't exist
    _timetableData[entry.facultyId] ??= {};
    _timetableData[entry.facultyId]![entry.className] ??= {};
    _timetableData[entry.facultyId]![entry.className]![
        entry.dayOfWeek.toString()] ??= {};

    // Add the entry
    _timetableData[entry.facultyId]![entry.className]![
        entry.dayOfWeek.toString()]![entry.period.toString()] = entry.toJson();
  }

  // Get faculty schedule
  Stream<List<TimetableEntry>> getFacultySchedule(String facultyId) async* {
    if (!_timetableData.containsKey(facultyId)) {
      yield [];
      return;
    }

    final entries = <TimetableEntry>[];
    _timetableData[facultyId]!.forEach((className, days) {
      days.forEach((day, periods) {
        periods.forEach((period, data) {
          entries.add(TimetableEntry.fromJson(data));
        });
      });
    });

    yield entries;
  }

  // Get class schedule
  Stream<List<TimetableEntry>> getClassSchedule(String className) async* {
    final entries = <TimetableEntry>[];

    _timetableData.forEach((facultyId, classes) {
      if (classes.containsKey(className)) {
        classes[className]!.forEach((day, periods) {
          periods.forEach((period, data) {
            entries.add(TimetableEntry.fromJson(data));
          });
        });
      }
    });

    yield entries;
  }

  // Helper method to validate no conflicts
  Future<bool> hasConflict(TimetableEntry newEntry) async {
    // Check faculty conflicts
    final facultySchedule = await getFacultySchedule(newEntry.facultyId).first;
    final sameDayEntries =
        facultySchedule.where((entry) => entry.dayOfWeek == newEntry.dayOfWeek);

    // Check class conflicts
    final classSchedule = await getClassSchedule(newEntry.className).first;
    final sameDayClassEntries =
        classSchedule.where((entry) => entry.dayOfWeek == newEntry.dayOfWeek);

    // Check for period conflicts
    for (var entry in [...sameDayEntries, ...sameDayClassEntries]) {
      if (entry.period == newEntry.period) {
        return true;
      }
    }

    return false;
  }

  // Save timetable
  Future<void> saveTimetable({
    required String course,
    required String year,
    required String section,
    required Map<String, dynamic> timetableData,
  }) async {
    try {
      final docRef = _firestore
          .collection('timetables')
          .doc('$course-$year-$section');

      await docRef.set({
        'course': course,
        'year': year,
        'section': section,
        'timetable': timetableData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save timetable: $e';
    }
  }

  // Get timetable
  Future<Map<String, dynamic>?> getTimetable({
    required String course,
    required String year,
    required String section,
  }) async {
    try {
      final docRef = _firestore
          .collection('timetables')
          .doc('$course-$year-$section');

      final doc = await docRef.get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw 'Failed to get timetable: $e';
    }
  }

  // Update specific slot in timetable
  Future<void> updateTimeSlot({
    required String course,
    required String year,
    required String section,
    required String day,
    required String period,
    required Map<String, dynamic> slotData,
  }) async {
    try {
      final docRef = _firestore
          .collection('timetables')
          .doc('$course-$year-$section');

      await docRef.set({
        'timetable': {
          day: {
            period: slotData,
          }
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to update time slot: $e';
    }
  }

  // Delete specific slot from timetable
  Future<void> deleteTimeSlot({
    required String course,
    required String year,
    required String section,
    required String day,
    required String period,
  }) async {
    try {
      final docRef = _firestore
          .collection('timetables')
          .doc('$course-$year-$section');

      await docRef.update({
        'timetable.$day.$period': FieldValue.delete(),
      });
    } catch (e) {
      throw 'Failed to delete time slot: $e';
    }
  }

  // Get all timetables for a course
  Stream<QuerySnapshot> getTimetablesForCourse(String course) {
    return _firestore
        .collection('timetables')
        .where('course', isEqualTo: course)
        .snapshots();
  }

  // Check for conflicts in timetable
  Future<List<Map<String, dynamic>>> checkConflicts({
    required String course,
    required String teacher,
    required String day,
    required String period,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('timetables')
          .where('timetable.$day.$period.teacher', isEqualTo: teacher)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'course': doc['course'],
                'year': doc['year'],
                'section': doc['section'],
                'conflict': {
                  'day': day,
                  'period': period,
                  'teacher': teacher,
                }
              })
          .toList();
    } catch (e) {
      throw 'Failed to check conflicts: $e';
    }
  }

  // Backup timetable
  Future<void> backupTimetable({
    required String course,
    required String year,
    required String section,
  }) async {
    try {
      final sourceDoc = await _firestore
          .collection('timetables')
          .doc('$course-$year-$section')
          .get();

      if (sourceDoc.exists) {
        final data = sourceDoc.data()!;
        await _firestore
            .collection('timetable_backups')
            .doc('$course-$year-$section-${DateTime.now().millisecondsSinceEpoch}')
            .set({
          ...data,
          'backupDate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Failed to backup timetable: $e';
    }
  }

  // Get backup history
  Future<List<Map<String, dynamic>>> getBackupHistory({
    required String course,
    required String year,
    required String section,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('timetable_backups')
          .where('course', isEqualTo: course)
          .where('year', isEqualTo: year)
          .where('section', isEqualTo: section)
          .orderBy('backupDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw 'Failed to get backup history: $e';
    }
  }
}
