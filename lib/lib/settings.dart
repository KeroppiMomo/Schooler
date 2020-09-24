import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/external_value_notifier.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/lib/reminder.dart';

enum CalendarType { week, cycle }

class ParseJSONException implements Exception {
  final String message;
  ParseJSONException({this.message});

  @override
  String toString() {
    if (message == null)
      return 'ParseJSONException';
    else
      return 'ParseJSONException: $message';
  }
}

class Settings {
  // Singleton ---------------------------------------------------------------
  static Settings instance = Settings._();
  Settings._() {
    assignmentListener = ExternalValueNotifier(assignments);
    reminderListener = ExternalValueNotifier(reminders);
    timetableListener = ExternalValueNotifier(timetable);
  }
  factory Settings() => Settings.instance;

  // Fields ------------------------------------------------------------------
  CalendarType calendarType;
  CycleConfig cycleConfig;
  WeekConfig weekConfig;
  Timetable timetable;
  List<Subject> subjects;
  bool isSetupCompleted = false;

  Map<LocationReminderLocation, String> savedLocations = {};

  List<Assignment> assignments = [];
  List<Reminder> reminders = [];

  // Value Listener ----------------------------------------------------------
  ExternalValueNotifier<List<Assignment>> assignmentListener;
  ExternalValueNotifier<List<Reminder>> reminderListener;
  ExternalValueNotifier<Timetable> timetableListener;

  // Serilization & File -----------------------------------------------------

  /// Generate a JSON string from the current Settings.
  String generateJson() {
    return jsonEncode({
      'calendar_type': calendarType?.toString(),
      'cycle_config': cycleConfig?.toJSON(),
      'week_config': weekConfig?.toJSON(),
      'timetable': timetable?.toJSON(),
      'subjects': subjects?.map((subject) => subject.toJSON())?.toList(),
      'setup_completed': isSetupCompleted,
      'saved_locations':
          LocationReminderLocation.savedLocationsToJSON(savedLocations),
      'assignments':
          assignments?.map((assignment) => assignment.toJSON())?.toList(),
      'reminders': reminders?.map((reminder) => reminder.toJSON())?.toList(),
    });
  }

  /// Parse the `json` and replace it to `Settings()`.
  /// This function returns `Settings()`.
  static Settings loadJson(String json) {
    final decoded = jsonDecode(json);
    if (!(decoded is Map<String, Object>))
      throw ParseJSONException(
          message:
              'Master level type mismatch: ${decoded.runtimeType} found, Map<String, Object> expected');

    Settings().calendarType = CalendarType.values
        .where((value) => value.toString() == decoded['calendar_type'])
        .firstWhere((_) => true, orElse: () => null); // .first or null
    Settings().cycleConfig = CycleConfig.fromJSON(decoded['cycle_config']);
    Settings().weekConfig = WeekConfig.fromJSON(decoded['week_config']);
    Settings().timetable = Timetable.fromJSON(decoded['timetable']);
    Settings().subjects = Subject.fromJSONList(decoded['subjects']);
    if (decoded['setup_completed'] is bool) {
      Settings().isSetupCompleted = decoded['setup_completed'];
    } else {
      throw ParseJSONException(
          message:
              'isSetupCompleted type mismatch: ${decoded["setup_completed"].runtimeType} found; bool expected');
    }

    Settings().savedLocations = LocationReminderLocation.savedLocationsFromJSON(
            decoded['saved_locations']) ??
        {};

    Settings().assignments =
        Assignment.fromJSONList(decoded['assignments']) ?? [];
    Settings().reminders = Reminder.fromJSONList(decoded['reminders']) ?? [];

    return Settings();
  }

  /// Save the settings to `$DOCUMENTS/settings.json`.
  Future<void> saveSettings() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentsDirectory.path}/settings.json');
    await file.writeAsString(generateJson());
  }

  /// Load the settings from `$DOCUMENTS/settings.json` and replace it to `Settings()`.
  /// This function returns `Settings()`.
  static Future<Settings> loadSettings() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentsDirectory.path}/settings.json');
    final jsonString = await file.readAsString();
    loadJson(jsonString);

    return Settings();
  }
}
