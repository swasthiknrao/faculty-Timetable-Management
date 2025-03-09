import '../models/timetable_entry.dart';

class TimetableService {
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
}
