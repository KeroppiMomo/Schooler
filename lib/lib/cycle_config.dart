import 'package:uuid/uuid.dart';

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
}
