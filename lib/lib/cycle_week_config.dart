import 'package:quiver/core.dart';
import 'package:schooler/lib/settings.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

/// Convert a `DateTime` into UTC using its `year`, `month`, and `day`. Used
DateTime removeTimeFrom(DateTime dateTime) {
  return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
}

/// Convert a number of millisecond since epoch to DateTime.
/// If `msSinceEpoch` is `null`, returns `null`.
DateTime nullableUnixEpochToDateTime(int msSinceEpoch) => msSinceEpoch == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);

class Event {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;

  /// For `CalendarType.week`, this value should be `false`.
  bool skipDay;

  Event({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.skipDay,
  });

  static String generateID() => Uuid().v1();

  // Serilization --------------------------------------------------------------
  Map<String, Object> toJSON() {
    return {
      'id': id,
      'name': name,
      'start_date_epoch_ms': startDate?.millisecondsSinceEpoch,
      'end_date_epoch_ms': endDate?.millisecondsSinceEpoch,
      'skip_day': skipDay,
    };
  }

  static Event fromJSON(Map<String, Object> json) {
    final id = json['id'];
    final name = json['name'];
    final startDateEpochMS = json['start_date_epoch_ms'];
    final endDateEpochMS = json['end_date_epoch_ms'];
    final skipDay = json['skip_day'];
    if ((id is String || id == null) &&
        (name is String || name == null) &&
        (startDateEpochMS is int || startDateEpochMS == null) &&
        (endDateEpochMS is int || endDateEpochMS == null) &&
        (skipDay is bool || skipDay == null)) {
      return Event(
        id: id,
        name: name,
        startDate: nullableUnixEpochToDateTime(startDateEpochMS),
        endDate: nullableUnixEpochToDateTime(endDateEpochMS),
        skipDay: skipDay,
      );
    } else {
      final curTypeMessage = [
        'id',
        'name',
        'start_date_epoch_ms',
        'end_date_epoch_ms',
        'skip_day'
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'Event type mismatch: $curTypeMessage found; String, String, int, int, bool expected');
    }
  }

  // Identity -------------------------------------------------------
  bool operator ==(other) {
    return other is Event &&
        other.id == this.id &&
        other.name == this.name &&
        other.startDate == this.startDate &&
        other.endDate == this.endDate &&
        other.skipDay == this.skipDay;
  }

  int get hashCode => hashObjects([id, name, startDate, endDate, skipDay]);
}

/// Information in a calendar for a day.
class CalendarDayInfo {
  /// Indicate whether the day is the start of school year.
  bool isStartSchoolYear;

  /// Indicate whether the day is the end of school year.
  bool isEndSchoolYear;

  /// Day in a cycle.
  String cycleDay;

  /// Number of cycle of the day.
  int cycle;

  /// `null` if not a holiday. `""` if weekend. Name of the holidays separated by commas if otherwise.
  String holidays;

  /// `null` if not a occasion. Name of the occasions separated by commas if otherwise.
  String occasions;

  CalendarDayInfo({
    this.isStartSchoolYear = false,
    this.isEndSchoolYear = false,
    this.cycleDay,
    this.cycle,
    this.holidays,
    this.occasions,
  });
}

class CycleConfig {
  DateTime startSchoolYear;
  DateTime endSchoolYear;
  int noOfDaysInCycle;
  bool isSaturdayHoliday;
  bool isSundayHoliday;
  List<Event> holidays;
  List<Event> occasions;

  CycleConfig({
    this.startSchoolYear,
    this.endSchoolYear,
    this.noOfDaysInCycle,
    this.isSaturdayHoliday,
    this.isSundayHoliday,
    this.holidays,
    this.occasions,
  });

  Map<DateTime, CalendarDayInfo> getCalendar() {
    final results = Map<DateTime, CalendarDayInfo>();

    DateTime curDate = removeTimeFrom(startSchoolYear);
    int curCycleDay = 1;
    int curCycle = 1;
    while (!curDate.isAfter(removeTimeFrom(endSchoolYear))) {
      results[curDate] = CalendarDayInfo();

      bool isSkipDay = false;

      if ((isSaturdayHoliday && curDate.weekday == DateTime.saturday) ||
          (isSundayHoliday && curDate.weekday == DateTime.sunday)) {
        results[curDate].holidays = '';
        isSkipDay = true;
      }

      List<Event> getCurrentEvents(List<Event> events) => events
          .where((event) =>
              removeTimeFrom(event.startDate).compareTo(curDate) <= 0 &&
              removeTimeFrom(event.endDate).compareTo(curDate) >= 0)
          .toList();

      List<Event> curHolidays = getCurrentEvents(holidays);
      if (curHolidays != null && curHolidays.length != 0) {
        results[curDate].holidays =
            curHolidays.map((event) => event.name).join(', ');
        if (curHolidays.any((event) => event.skipDay)) {
          isSkipDay = true;
        }
      }

      List<Event> curOccasions = getCurrentEvents(occasions);
      if (curOccasions != null && curOccasions.length != 0) {
        results[curDate].occasions =
            curOccasions.map((event) => event.name).join(', ');
        if (curOccasions.any((event) => event.skipDay)) {
          isSkipDay = true;
        }
      }

      if (!isSkipDay) {
        results[curDate].cycleDay = curCycleDay.toString();
        results[curDate].cycle = curCycle;

        if (curCycleDay == noOfDaysInCycle) {
          curCycleDay = 1;
          curCycle++;
        } else {
          curCycleDay++;
        }
      }

      curDate = curDate.add(Duration(days: 1));
    }
    results[removeTimeFrom(startSchoolYear)].isStartSchoolYear = true;
    results[removeTimeFrom(endSchoolYear)].isEndSchoolYear = true;

    return results;
  }

  // Serilization -----------------------------------------------------------
  Map<String, Object> toJSON() {
    return {
      'start_school_year_epoch_ms': startSchoolYear == null
          ? null
          : startSchoolYear.millisecondsSinceEpoch,
      'end_school_year_epoch_ms':
          endSchoolYear == null ? null : endSchoolYear.millisecondsSinceEpoch,
      'days_in_cycle': noOfDaysInCycle,
      'is_sat_holiday': isSaturdayHoliday,
      'is_sun_holiday': isSundayHoliday,
      'holidays': (holidays ?? []).map((event) => event.toJSON()).toList(),
      'occasions': (occasions ?? []).map((event) => event.toJSON()).toList(),
    };
  }

  static CycleConfig fromJSON(Map<String, Object> json) {
    if (json == null) return null;

    final dynamic startSchoolYearEpochMS = json['start_school_year_epoch_ms'];
    final dynamic endSchoolYearEpochMS = json['end_school_year_epoch_ms'];
    final dynamic daysInCycle = json['days_in_cycle'];
    final dynamic isSatHoliday = json['is_sat_holiday'];
    final dynamic isSunHoliday = json['is_sun_holiday'];
    final dynamic holidays = json['holidays'];
    final dynamic occasions = json['occasions'];

    bool isStringObjectMapList(dynamic obj) {
      if (obj is! List) return false;
      try {
        obj.cast<Map<String, Object>>();
        return true;
      } catch (e) {
        return false;
      }
    }

    if ((startSchoolYearEpochMS is int || startSchoolYearEpochMS == null) &&
        (endSchoolYearEpochMS is int || endSchoolYearEpochMS == null) &&
        (daysInCycle is int || daysInCycle == null) &&
        (isSatHoliday is bool || isSatHoliday == null) &&
        (isSunHoliday is bool || isSunHoliday == null) &&
        (isStringObjectMapList(holidays) || holidays == null) &&
        (isStringObjectMapList(occasions) || occasions == null)) {
      return CycleConfig(
        startSchoolYear: nullableUnixEpochToDateTime(startSchoolYearEpochMS),
        endSchoolYear: nullableUnixEpochToDateTime(endSchoolYearEpochMS),
        noOfDaysInCycle: daysInCycle,
        isSaturdayHoliday: isSatHoliday,
        isSundayHoliday: isSunHoliday,
        holidays: holidays
            .map((event) => Event.fromJSON(event))
            .toList()
            .cast<Event>(),
        occasions: occasions
            .map((event) => Event.fromJSON(event))
            .toList()
            .cast<Event>(),
      );
    } else {
      final curTypeMessage = [
        'start_school_year_epoch_ms',
        'end_school_year_epoch_ms',
        'days_in_cycle',
        'is_sat_holiday',
        'is_sun_holiday',
        'holidays',
        'occasions',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'CycleConfig type mismatch: $curTypeMessage found; int, int, int, bool, bool, List<Map<String, Object>>, List<Map<String, Object>> expected');
    }
  }

  // Identity -------------------------------------------------------
  bool operator ==(other) {
    return other is CycleConfig &&
        other.startSchoolYear == this.startSchoolYear &&
        other.endSchoolYear == this.endSchoolYear &&
        other.noOfDaysInCycle == this.noOfDaysInCycle &&
        other.isSaturdayHoliday == this.isSaturdayHoliday &&
        other.isSundayHoliday == this.isSundayHoliday &&
        listEquals(other.holidays, this.holidays) &&
        listEquals(other.occasions, this.occasions);
  }

  int get hashCode => hashObjects([
        startSchoolYear,
        endSchoolYear,
        noOfDaysInCycle,
        isSaturdayHoliday,
        isSundayHoliday,
        holidays,
        occasions
      ]);
}

class WeekConfig {
  DateTime startSchoolYear;
  DateTime endSchoolYear;
  bool isSaturdayHoliday;
  bool isSundayHoliday;
  List<Event> holidays;
  List<Event> occasions;

  WeekConfig({
    this.startSchoolYear,
    this.endSchoolYear,
    this.isSaturdayHoliday,
    this.isSundayHoliday,
    this.holidays,
    this.occasions,
  });

  Map<DateTime, CalendarDayInfo> getCalendar() {
    final results = Map<DateTime, CalendarDayInfo>();

    DateTime curDate = removeTimeFrom(startSchoolYear);
    while (!curDate.isAfter(removeTimeFrom(endSchoolYear))) {
      results[curDate] = CalendarDayInfo();

      if ((isSaturdayHoliday && curDate.weekday == DateTime.saturday) ||
          (isSundayHoliday && curDate.weekday == DateTime.sunday)) {
        results[curDate].holidays = '';
      }

      List<Event> getCurrentEvents(List<Event> events) => events
          .where((event) =>
              removeTimeFrom(event.startDate).compareTo(curDate) <= 0 &&
              removeTimeFrom(event.endDate).compareTo(curDate) >= 0)
          .toList();

      List<Event> curHolidays = getCurrentEvents(holidays);
      if (curHolidays != null && curHolidays.length != 0) {
        results[curDate].holidays =
            curHolidays.map((event) => event.name).join(', ');
      }

      List<Event> curOccasions = getCurrentEvents(occasions);
      if (curOccasions != null && curOccasions.length != 0) {
        results[curDate].occasions =
            curOccasions.map((event) => event.name).join(', ');
      }

      results[curDate].cycleDay = curDate.weekday.toString();

      curDate = curDate.add(Duration(days: 1));
    }
    results[removeTimeFrom(startSchoolYear)].isStartSchoolYear = true;
    results[removeTimeFrom(endSchoolYear)].isEndSchoolYear = true;

    return results;
  }

  // Serilization -----------------------------------------------------------
  Map<String, Object> toJSON() {
    return {
      'start_school_year_epoch_ms': startSchoolYear == null
          ? null
          : startSchoolYear.millisecondsSinceEpoch,
      'end_school_year_epoch_ms':
          endSchoolYear == null ? null : endSchoolYear.millisecondsSinceEpoch,
      'is_sat_holiday': isSaturdayHoliday,
      'is_sun_holiday': isSundayHoliday,
      'holidays': (holidays ?? []).map((event) => event.toJSON()).toList(),
      'occasions': (occasions ?? []).map((event) => event.toJSON()).toList(),
    };
  }

  static WeekConfig fromJSON(Map<String, Object> json) {
    final dynamic startSchoolYearEpochMS = json['start_school_year_epoch_ms'];
    final dynamic endSchoolYearEpochMS = json['end_school_year_epoch_ms'];
    final dynamic isSatHoliday = json['is_sat_holiday'];
    final dynamic isSunHoliday = json['is_sun_holiday'];
    final dynamic holidays = json['holidays'];
    final dynamic occasions = json['occasions'];

    bool isStringObjectMapList(dynamic obj) {
      if (obj is! List) return false;
      try {
        obj.cast<Map<String, Object>>();
        return true;
      } catch (e) {
        return false;
      }
    }

    if ((startSchoolYearEpochMS is int || startSchoolYearEpochMS == null) &&
        (endSchoolYearEpochMS is int || endSchoolYearEpochMS == null) &&
        (isSatHoliday is bool || isSatHoliday == null) &&
        (isSunHoliday is bool || isSunHoliday == null) &&
        (isStringObjectMapList(holidays) || holidays == null) &&
        (isStringObjectMapList(occasions) || occasions == null)) {
      return WeekConfig(
        startSchoolYear: nullableUnixEpochToDateTime(startSchoolYearEpochMS),
        endSchoolYear: nullableUnixEpochToDateTime(endSchoolYearEpochMS),
        isSaturdayHoliday: isSatHoliday,
        isSundayHoliday: isSunHoliday,
        holidays: holidays
            .map((event) => Event.fromJSON(event))
            .toList()
            .cast<Event>(),
        occasions: occasions
            .map((event) => Event.fromJSON(event))
            .toList()
            .cast<Event>(),
      );
    } else {
      final curTypeMessage = [
        'start_school_year_epoch_ms',
        'end_school_year_epoch_ms',
        'is_sat_holiday',
        'is_sun_holiday',
        'holidays',
        'occasions',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'WeekConfig type mismatch: $curTypeMessage found; int, int, bool, bool, List<Map<String, Object>>, List<Map<String, Object>> expected');
    }
  }

  // Identity -------------------------------------------------------
  bool operator ==(other) {
    return other is WeekConfig &&
        other.startSchoolYear == this.startSchoolYear &&
        other.endSchoolYear == this.endSchoolYear &&
        other.isSaturdayHoliday == this.isSaturdayHoliday &&
        other.isSundayHoliday == this.isSundayHoliday &&
        listEquals(other.holidays, this.holidays) &&
        listEquals(other.occasions, this.occasions);
  }

  int get hashCode => hashObjects([
        startSchoolYear,
        endSchoolYear,
        isSaturdayHoliday,
        isSundayHoliday,
        holidays,
        occasions
      ]);
}
