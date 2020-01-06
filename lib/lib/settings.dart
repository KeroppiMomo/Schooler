import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:schooler/lib/cycle_config.dart';

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
  Settings._();
  factory Settings() => Settings.instance;

  // Fields ------------------------------------------------------------------
  CalendarType calendarType;
  CycleConfig cycleConfig;

  // Serilization & File -----------------------------------------------------

  /// Generate a JSON string from the current Settings.
  String generateJson() {
    return jsonEncode({
      'calendar_type': calendarType?.toString(),
      'cycle_config': cycleConfig?.toJSON(),
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
