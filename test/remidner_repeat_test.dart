import 'package:flutter_test/flutter_test.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:schooler/lib/timetable.dart';

void main() {
  group('(TimeReminderRepeat isDateMatched)', () {
    final config = CycleConfig(
      startSchoolYear: DateTime(2000, 5, 13),
      endSchoolYear: DateTime(2001, 5, 13),
      isSundayHoliday: true,
      isSaturdayHoliday: true,
      noOfDaysInCycle: 6,
      holidays: [
        Event(
          id: 'ID1',
          name: 'N1',
          startDate: DateTime(2000, 9, 1),
          endDate: DateTime(2000, 9, 10),
        ),
        Event(
          id: 'ID2',
          name: 'N2',
          startDate: DateTime(2000, 10, 1),
          endDate: DateTime(2000, 10, 2),
        ),
        Event(
          id: 'ID3',
          name: 'N3',
          startDate: DateTime(2000, 12, 23),
          endDate: DateTime(2000, 12, 25),
        ),
        Event(
          id: 'ID4',
          name: 'N1',
          startDate: DateTime(2000, 12, 24),
          endDate: DateTime(2000, 12, 31),
        ),
      ],
      occasions: [
        Event(
          id: 'ID5',
          name: 'N1',
          startDate: DateTime(2001, 2, 5),
          endDate: DateTime(2001, 2, 5),
        ),
      ],
      skippedDays: [],
    );
    final calendar = config.getCalendar();

    test('[Dates over one year to TimeReminderRepeat.day] {All returns true}',
        () {
      for (DateTime curDate = DateTime(2000, 5, 13);
          curDate.isBefore(DateTime(2001, 5, 13));
          curDate = curDate.add(Duration(days: 1))) {
        expect(
            TimeReminderRepeat.day
                .isDateMatched(curDate, DateTime(2000, 5, 13), null),
            true);
      }
    });
    test(
        '[Dates over one year to TimeReminderRepeat.weekDay] {Returns whether the weekday matches}',
        () {
      for (int day = 1; day <= 7; day++) {
        for (DateTime curDate = DateTime(2000, 5, 13);
            curDate.isBefore(DateTime(2001, 5, 13));
            curDate = curDate.add(Duration(days: 1))) {
          bool isMatched = TimeReminderRepeat.weekDay(day)
              .isDateMatched(curDate, DateTime(2000, 5, 13), null);
          expect(isMatched, (curDate.weekday == day));
        }
      }
    });
    test(
        '[Dates over one year to TimeReminderRepeat.timetableDay TimetableWeekDay] {Returns whether the weekday matches}',
        () {
      for (int day = 1; day <= 7; day++) {
        for (DateTime curDate = DateTime(2000, 5, 13);
            curDate.isBefore(DateTime(2001, 5, 13));
            curDate = curDate.add(Duration(days: 1))) {
          bool isMatched =
              TimeReminderRepeat.timetableDay(TimetableWeekDay(day))
                  .isDateMatched(curDate, DateTime(2000, 5, 13), calendar);
          expect(isMatched, (curDate.weekday == day));
        }
      }
    });
    test(
        '[Dates over one year to TimeReminderRepeat.timetableDay TimetableCycleDay] {Returns whether the cycle day matches}',
        () {
      for (int day = 1; day <= 6; day++) {
        for (DateTime curDate = DateTime(2000, 5, 13);
            curDate.isBefore(DateTime(2001, 5, 13));
            curDate = curDate.add(Duration(days: 1))) {
          bool isMatched =
              TimeReminderRepeat.timetableDay(TimetableCycleDay(day))
                  .isDateMatched(curDate, DateTime(2000, 5, 13), calendar);
          expect(isMatched,
              (calendar[removeTimeFrom(curDate)].cycleDay == day.toString()));
        }
      }
    });
    test(
        '[Dates over one year to TimeReminderRepeat.timetableDay TimetableOccasion] {Returns whether the day has the specified occasion}',
        () {
      for (DateTime curDate = DateTime(2000, 5, 13);
          curDate.isBefore(DateTime(2001, 5, 13));
          curDate = curDate.add(Duration(days: 1))) {
        bool isMatched =
            TimeReminderRepeat.timetableDay(TimetableOccasionDay('N1'))
                .isDateMatched(curDate, DateTime(2000, 5, 13), calendar);
        expect(
            isMatched,
            ([
              ...calendar[removeTimeFrom(curDate)].occasions ?? [],
              ...calendar[removeTimeFrom(curDate)].holidays ?? []
            ].any((event) => event.name == 'N1')));
      }
    });
    test(
        '[Dates over one year to TimeReminderRepeat.month] {Returns whether the day matches}',
        () {
      for (DateTime oriDate = DateTime(2000, 5, 13);
          oriDate.isBefore(DateTime(2000, 7, 13));
          oriDate = oriDate.add(Duration(days: 1))) {
        for (DateTime curDate = DateTime(2000, 5, 13);
            curDate.isBefore(DateTime(2001, 5, 13));
            curDate = curDate.add(Duration(days: 1))) {
          bool isMatched =
              TimeReminderRepeat.month.isDateMatched(curDate, oriDate, null);
          expect(isMatched, (curDate.day == oriDate.day));
        }
      }
    });
    test(
        '[Dates over one year to TimeReminderRepeat.year] {Returns whether the day and month matches}',
        () {
      for (DateTime oriDate = DateTime(2000, 5, 13);
          oriDate.isBefore(DateTime(2000, 7, 13));
          oriDate = oriDate.add(Duration(days: 10))) {
        for (DateTime curDate = DateTime(2000, 5, 13);
            curDate.isBefore(DateTime(2010, 5, 13));
            curDate = curDate.add(Duration(days: 1))) {
          bool isMatched =
              TimeReminderRepeat.year.isDateMatched(curDate, oriDate, null);
          expect(isMatched,
              (curDate.day == oriDate.day && curDate.month == oriDate.month));
        }
      }
    });
  });
}
