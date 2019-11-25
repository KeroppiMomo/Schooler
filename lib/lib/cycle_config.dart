import 'package:uuid/uuid.dart';

/// The information in a calendar for a day. Used in the key of the `Map` in `CycleConfig.getCalendar`.
enum DayInfoType {
  /// Indicate whether the day is the start of school year. Value should be of type `bool`.
  startSchoolYear,

  /// Indicate whether the day is the end of school year. Value should be of type `bool`.
  endSchoolYear,

  /// Day in a cycle. Value should be of type `string`.
  cycleDay,

  /// Number of cycle of the day. Value should be of type `int`.
  cycle,

  /// Name of the holidays of the day, separated by commas. Value should be of type `string`.
  holidays,

  /// Name of the occasions of the day, separated by commas. Value should be of type `string`.
  occasions,
}

/// Convert a `DateTime` into UTC using its `year`, `month`, and `day`. Used
DateTime removeTimeFrom(DateTime dateTime) {
  return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
}

class Event {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  bool skipDay;

  Event({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.skipDay,
  });

  static String generateID() => Uuid().v1();
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

  Map<DateTime, Map<DayInfoType, Object>> getCalendar() {
    final results = Map<DateTime, Map<DayInfoType, Object>>();

    DateTime curDate = removeTimeFrom(startSchoolYear);
    int curCycleDay = 1;
    int curCycle = 1;
    while (!curDate.isAfter(removeTimeFrom(endSchoolYear))) {
      results[curDate] = {};

      bool isSkipDay = false;

      if ((isSaturdayHoliday && curDate.weekday == DateTime.saturday) ||
          (isSundayHoliday && curDate.weekday == DateTime.sunday)) {
        results[curDate][DayInfoType.holidays] = '';
        isSkipDay = true;
      }

      List<Event> getCurrentEvents(List<Event> events) => events
          .where((event) =>
              removeTimeFrom(event.startDate).compareTo(curDate) <= 0 &&
              removeTimeFrom(event.endDate).compareTo(curDate) >= 0)
          .toList();

      List<Event> curHolidays = getCurrentEvents(holidays);
      if (curHolidays != null && curHolidays.length != 0) {
        results[curDate][DayInfoType.holidays] =
            curHolidays.map((event) => event.name).join(', ');
        if (curHolidays.any((event) => event.skipDay)) {
          isSkipDay = true;
        }
      }

      List<Event> curOccasions = getCurrentEvents(occasions);
      if (curOccasions != null && curOccasions.length != 0) {
        results[curDate][DayInfoType.occasions] =
            curOccasions.map((event) => event.name).join(', ');
        if (curOccasions.any((event) => event.skipDay)) {
          isSkipDay = true;
        }
      }

      if (!isSkipDay) {
        results[curDate][DayInfoType.cycleDay] = curCycleDay.toString();
        results[curDate][DayInfoType.cycle] = curCycle;

        if (curCycleDay == noOfDaysInCycle) {
          curCycleDay = 1;
          curCycle++;
        } else {
          curCycleDay++;
        }
      }

      curDate = curDate.add(Duration(days: 1));
    }
    results[removeTimeFrom(startSchoolYear)][DayInfoType.startSchoolYear] =
        true;
    results[removeTimeFrom(endSchoolYear)][DayInfoType.endSchoolYear] = true;

    return results;
  }
}
