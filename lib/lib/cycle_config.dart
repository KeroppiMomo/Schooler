enum DayInfoType {
  startSchoolYear,
  endSchoolYear,
  cycleDay,
  holiday,
  occasions,
}

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
    while (!curDate.isAfter(removeTimeFrom(endSchoolYear))) {
      results[curDate] = {};

      bool isSkipDay = false;

      if ((isSaturdayHoliday && curDate.weekday == DateTime.saturday) ||
          (isSundayHoliday && curDate.weekday == DateTime.sunday)) {
        results[curDate][DayInfoType.holiday] = '';
        isSkipDay = true;
      }

      List<Event> getCurrentEvents(List<Event> events) => events
          .where((event) =>
              removeTimeFrom(event.startDate).compareTo(curDate) <= 0 &&
              removeTimeFrom(event.endDate).compareTo(curDate) >= 0)
          .toList();

      List<Event> curHolidays = getCurrentEvents(holidays);
      if (curHolidays != null && curHolidays.length != 0) {
        results[curDate][DayInfoType.holiday] =
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

        if (curCycleDay == noOfDaysInCycle) {
          curCycleDay = 1;
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
