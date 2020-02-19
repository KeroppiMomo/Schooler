import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/settings.dart';
import 'package:quiver/core.dart';
import 'package:collection/collection.dart';

// Timetable Day ---------------------------------------------
abstract class TimetableDay {
  /// Returns a [String] identifing the type of [TimetableDay].
  /// For example, [TimetableWeekDay] has `'week'` as its [jsonType].
  String jsonType();

  /// The value of the TimetableDay.
  /// The return type should be JSON serilizable.
  Object jsonValue();

  /// Parse JSON type and value to a [TimetableDay] with appropiate subtype.
  /// If the type and value do not match any subtype format, a [ParseJSONException] will be thrown.
  ///
  /// Override this to check whether the JSON type and value is your class.
  /// If it is, return the TimetableDay instance. Otherwise, return null.
  static TimetableDay fromJSON(String type, Object value) {
    // Add new functions here if a new TimetableDay is added in the future
    final checkingFunctions = <TimetableDay Function(String, Object)>[
      TimetableWeekDay.fromJSON,
      TimetableCycleDay.fromJSON,
      TimetableOccasionDay.fromJSON,
    ];
    for (final func in checkingFunctions) {
      final result = func(type, value);
      if (result != null) return result;
    }

    throw ParseJSONException(
      message:
          'No matching TimetableDay subtype for type "$type" and value "$value".\n ' +
              'If a new subtype of TimetableDay is added, add its fromJSON function in the checkingFunctions above.',
    );
  }
}

class TimetableWeekDay extends TimetableDay {
  int dayOfWeek;
  TimetableWeekDay(this.dayOfWeek);

  String jsonType() => 'week';
  Object jsonValue() => dayOfWeek;
  static TimetableDay fromJSON(String type, Object value) {
    if (type != 'week' || (value is! int && value != null)) return null;
    return TimetableWeekDay(value);
  }

  bool operator ==(o) => o is TimetableWeekDay && o.dayOfWeek == this.dayOfWeek;
  int get hashCode => hash2(dayOfWeek.hashCode, 'TimetableWeekDay'.hashCode);
}

class TimetableCycleDay extends TimetableDay {
  int dayOfCycle;
  TimetableCycleDay(this.dayOfCycle);

  String jsonType() => 'cycle';
  Object jsonValue() => dayOfCycle;
  static TimetableDay fromJSON(String type, Object value) {
    if (type != 'cycle' || (value is! int && value != null)) return null;
    return TimetableCycleDay(value);
  }

  bool operator ==(o) =>
      o is TimetableCycleDay && o.dayOfCycle == this.dayOfCycle;
  int get hashCode => hash2(dayOfCycle.hashCode, 'TimetableCycleDay'.hashCode);
}

class TimetableOccasionDay extends TimetableDay {
  String occasionName;
  TimetableOccasionDay(this.occasionName);

  String jsonType() => 'occasion';
  Object jsonValue() => occasionName;
  static TimetableDay fromJSON(String type, Object value) {
    if (type != 'occasion' || (value is! String && value != null)) return null;
    return TimetableOccasionDay(value);
  }

  bool operator ==(o) =>
      o is TimetableOccasionDay && o.occasionName == this.occasionName;
  int get hashCode =>
      hash2(occasionName.hashCode, 'TimetableOccasionDay'.hashCode);
}

// Timetable Session -----------------------------------------
class TimetableSession {
  DateTime startTime;
  DateTime endTime;
  String name;

  TimetableSession({this.startTime, this.endTime, this.name});

  // Serilization -------------------------------------------
  Map<String, Object> toJSON() {
    return {
      'start_epoch_ms': startTime?.millisecondsSinceEpoch,
      'end_epoch_ms': endTime?.millisecondsSinceEpoch,
      'name': name,
    };
  }

  static TimetableSession fromJSON(Map<String, Object> json) {
    if (json == null) return null;

    final dynamic startEpochMS = json['start_epoch_ms'];
    final dynamic endEpochMS = json['end_epoch_ms'];
    final dynamic name = json['name'];

    if ((startEpochMS is int || startEpochMS == null) &&
        (endEpochMS is int || endEpochMS == null) &&
        (name is String || name == null)) {
      return TimetableSession(
        startTime: nullableUnixEpochToDateTime(startEpochMS),
        endTime: nullableUnixEpochToDateTime(endEpochMS),
        name: name,
      );
    } else {
      final curTypeMessage = [
        'start_epoch_ms',
        'end_epoch_ms',
        'name',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'TimetableSession type mismatch: $curTypeMessage found; int, int, String expected');
    }
  }

  // Equality ---------------------------------------
  bool operator ==(o) =>
      o is TimetableSession &&
      o.startTime == this.startTime &&
      o.endTime == this.endTime &&
      o.name == this.name;
  int get hashCode =>
      hash3(startTime.hashCode, endTime.hashCode, name.hashCode);
}

// Timetable
class Timetable {
  Map<TimetableDay, List<TimetableSession>> timetable;
  Timetable(this.timetable);
  factory Timetable.defaultFromCycleConfig(CycleConfig config) {
    Timetable result = Timetable({});
    for (int i = 1; i <= config.noOfDaysInCycle; i++) {
      result.timetable[TimetableCycleDay(i)] = [];
    }
    return result;
  }
  factory Timetable.defaultFromWeekConfig(WeekConfig config) {
    Timetable result = Timetable({});
    for (int i = 1; i <= 5; i++) {
      result.timetable[TimetableWeekDay(i)] = [];
    }
    if (!config.isSaturdayHoliday) {
      result.timetable[TimetableWeekDay(6)] = [];
    }
    if (!config.isSundayHoliday) {
      result.timetable[TimetableWeekDay(7)] = [];
    }
    return result;
  }

  int get noOfDays => timetable.length;
  List<TimetableSession> sessionsOfDay(TimetableDay day) => timetable[day];
  List<TimetableDay> get days => timetable.keys.toList();

  // Serilization -------------------------------------------------------
  List<Map<String, Object>> toJSON() {
    return timetable.entries
        .map((entry) => {
              'day_type': entry.key.jsonType(),
              'day_value': entry.key.jsonValue(),
              'sessions':
                  entry.value.map((session) => session.toJSON()).toList(),
            })
        .toList();
  }

  static Timetable fromJSON(dynamic json) {
    bool isStringObjectMapList(dynamic obj) {
      if (obj is! List) return false;
      try {
        obj.cast<Map<String, Object>>();
        return true;
      } catch (e) {
        return false;
      }
    }

    if (json == null) return null;
    if (!isStringObjectMapList(json))
      throw ParseJSONException(
          message:
              'Timetable type mismatch: ${json.runtimeType} found; List<Map<String, Object>> expected.');
    final jsonList = (json as List).cast<Map<String, Object>>();

    final result = Map<TimetableDay, List<TimetableSession>>();
    for (final map in jsonList) {
      final dynamic dayType = map['day_type'];
      final Object dayValue = map['day_value'];
      final dynamic sessionsJSON = map['sessions'];

      if ((dayType is String || dayType == null) &&
          (isStringObjectMapList(sessionsJSON) || sessionsJSON == null)) {
        final day = TimetableDay.fromJSON(dayType, dayValue);
        final List<TimetableSession> sessions = (sessionsJSON as List)
            .cast<Map<String, Object>>()
            .map(TimetableSession.fromJSON)
            .toList();
        result[day] = sessions;
      } else {
        final curTypeMessage = [
          'day_type',
          'day_value',
          'sessions',
        ].map((key) => key + ': ' + map[key].runtimeType.toString()).join(', ');
        throw ParseJSONException(
            message:
                'Timetable Entry type mismatch: $curTypeMessage found; String, Object, List<Map<String, Object>> expected');
      }
    }

    return Timetable(result);
  }

  // Equality ----------------------------------------------
  operator ==(other) =>
      other is Timetable &&
      MapEquality(values: ListEquality()).equals(other.timetable,
          this.timetable); // Require MapEquality and ListEquality to compare
  int get hashCode => timetable.hashCode;
}
