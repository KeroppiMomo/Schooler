import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:geofencing/geofencing.dart';
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/lib/subject.dart';

void main() {
  group('(serilization)', () {
    group('(Event)', () {
      test(
          '[toJSON then fromJSON, all field non-null] {return original Event object}',
          () {
        final event = Event(
          id: 'id',
          name: 'name',
          startDate: DateTime(2000, 1, 1),
          endDate: DateTime(2000, 12, 31),
          skipDay: false,
        );
        final toJSONed = event.toJSON();
        final fromJSONed = Event.fromJSON(toJSONed);

        expect(fromJSONed, event);
      });
      test(
          '[toJSON then fromJSON, all field null] {return original Event object}',
          () {
        final event = Event(
          id: null,
          name: null,
          startDate: null,
          endDate: null,
          skipDay: null,
        );
        final toJSONed = event.toJSON();
        final fromJSONed = Event.fromJSON(toJSONed);

        expect(fromJSONed, event);
      });
    });

    group('(CycleConfig)', () {
      test(
          '[toJSON then fromJSON, all field non-null] {return original CycleConfig object}',
          () {
        final config = CycleConfig(
          startSchoolYear: DateTime(2000, 1, 1),
          endSchoolYear: DateTime(2000, 12, 31),
          noOfDaysInCycle: 8,
          isSaturdayHoliday: true,
          isSundayHoliday: false,
          holidays: [
            Event(id: 'H1'),
            Event(id: 'H2'),
          ],
          occasions: [
            Event(id: 'O1'),
            Event(id: 'O2'),
            Event(id: 'O3'),
          ],
        );

        final toJSONed = config.toJSON();
        final fromJSONed = CycleConfig.fromJSON(toJSONed);

        expect(fromJSONed, config);
      });
      test(
          '[toJSON then fromJSON, all field null] {return original CycleConfig object}',
          () {
        final config = CycleConfig(
          startSchoolYear: null,
          endSchoolYear: null,
          noOfDaysInCycle: null,
          isSaturdayHoliday: null,
          isSundayHoliday: null,
          holidays: null,
          occasions: null,
        );

        final toJSONed = config.toJSON();
        final fromJSONed = CycleConfig.fromJSON(toJSONed);

        expect(
          fromJSONed,
          CycleConfig(
            startSchoolYear: null,
            endSchoolYear: null,
            noOfDaysInCycle: null,
            isSaturdayHoliday: null,
            isSundayHoliday: null,
            holidays: [],
            occasions: [],
          ),
        );
      });
    });

    group('(TimetableDay)', () {
      group('(TimetableWeekDay)', () {
        test(
            '[toJSON then fromJSON, weekDay non-null] {return original object}',
            () {
          final day = TimetableWeekDay(3);
          final type = day.jsonType();
          final value = day.jsonValue();

          expect(TimetableDay.fromJSON(type, value), day);
        });
        test('[toJSON then fromJSON, weekDay null] {return original object}',
            () {
          final day = TimetableWeekDay(null);
          final type = day.jsonType();
          final value = day.jsonValue();

          expect(TimetableDay.fromJSON(type, value), day);
        });
      });
      group('(TimetableCycleDay)', () {
        test(
            '[toJSON then fromJSON, cycleDay non-null] {return original object}',
            () {
          final day = TimetableCycleDay(3);
          final type = day.jsonType();
          final value = day.jsonValue();

          expect(TimetableDay.fromJSON(type, value), day);
        });
        test('[toJSON then fromJSON, cycleDay null] {return original object}',
            () {
          final day = TimetableCycleDay(null);
          final type = day.jsonType();
          final value = day.jsonValue();

          expect(TimetableDay.fromJSON(type, value), day);
        });
      });
      group('(TimetableOccasionDay)', () {
        test(
            '[toJSON then fromJSON, occasionName non-null] {return original object}',
            () {
          final day = TimetableOccasionDay('N');
          final type = day.jsonType();
          final value = day.jsonValue();

          expect(TimetableDay.fromJSON(type, value), day);
        });
        test(
            '[toJSON then fromJSON, occasionName null] {return original object}',
            () {
          final day = TimetableOccasionDay(null);
          final type = day.jsonType();
          final value = day.jsonValue();

          expect(TimetableDay.fromJSON(type, value), day);
        });
      });

      test('[fromJSON, non-matching type and value] {throw ParseJSONException}',
          () {
        expect(() => TimetableDay.fromJSON('holiday', 'value'),
            throwsA(isA<ParseJSONException>()));
      });
    });

    group('(TimetableSession)', () {
      test(
          '[toJSON then fromJSON, all fields non-null] {return original object}',
          () {
        final session = TimetableSession(
          startTime: DateTime(1970, 1, 1, 8, 25),
          endTime: DateTime(1970, 1, 1, 13, 5),
          name: 'S',
        );
        final toJSONed = session.toJSON();
        final fromJSONed = TimetableSession.fromJSON(toJSONed);
        expect(fromJSONed, session);
      });
      test('[toJSON then fromJSON, all fields null] {return original object}',
          () {
        final session = TimetableSession(
          startTime: null,
          endTime: null,
          name: null,
        );
        final toJSONed = session.toJSON();
        final fromJSONed = TimetableSession.fromJSON(toJSONed);
        expect(fromJSONed, session);
      });
    });

    group('(Timetable)', () {
      test('[toJSON then fromJSON] {return original object}', () {
        final timetable = Timetable({
          TimetableWeekDay(1): [
            TimetableSession(
              startTime: DateTime(1970, 1, 1, 8, 20),
              endTime: DateTime(1970, 1, 1, 12, 25),
              name: 'S11',
            ),
            TimetableSession(
              startTime: DateTime(1970, 1, 1, 15, 0),
              endTime: DateTime(1970, 1, 1, 18, 55),
              name: 'S12',
            ),
          ],
          TimetableWeekDay(2): [],
          TimetableCycleDay(5): [
            TimetableSession(
              startTime: DateTime(1970, 1, 1, 9, 30),
              endTime: DateTime(1970, 1, 1, 10, 5),
              name: 'S31',
            ),
          ],
          TimetableOccasionDay('O4'): [
            TimetableSession(
              startTime: DateTime(1970, 1, 1, 9, 30),
              endTime: DateTime(1970, 1, 1, 10, 5),
              name: 'S41',
            ),
            TimetableSession(
              startTime: DateTime(1970, 1, 1, 12, 30),
              endTime: DateTime(1970, 1, 1, 14, 50),
              name: 'S42',
            ),
          ],
          TimetableOccasionDay('O5'): [],
        });

        final toJSONed = timetable.toJSON();
        final fromJSONed = Timetable.fromJSON(toJSONed);
        expect(fromJSONed, timetable);
      });
    });

    group('(Subject)', () {
      test('[toJSON then fromJSON] {return the same object}', () {
        final subject = Subject('N', color: Color(0x23A9FB0C));
        final toJSONed = subject.toJSON();
        final fromJSONed = Subject.fromJSON(toJSONed);

        expect(fromJSONed, subject);
      });
      test('[List toJSON then fromJSONList] {return the same list}', () {
        final subjects = [
          Subject('N1', color: Colors.red.shade500),
          Subject('N2', color: Colors.green.shade500),
          Subject('N3', color: Color(0x3289A34A)),
        ];
        final toJSONed = subjects.map((subject) => subject.toJSON()).toList();
        final fromJSONed = Subject.fromJSONList(toJSONed);

        for (int i = 0; i < subjects.length - 1; i++) {
          expect(subjects[i], fromJSONed[i]);
        }
      });
    });

    group('(Assignment)', () {
      test(
          '[toJSON then fromJSON, all fields non-null] {return the same object}',
          () {
        final assignment = Assignment(
          isCompleted: true,
          name: 'N',
          description: 'D',
          subject: Subject('S', color: Color(0xFFFF0000)),
          dueDate: DateTime(2020, 2, 29, 15, 05),
          withDueTime: true,
          notes: 'Notes',
        );
        final toJSONed = assignment.toJSON();
        final fromJSONed = Assignment.fromJSON(toJSONed);

        expect(fromJSONed, assignment);
      });
      test('[toJSON then fromJSON, some fields null] {return the same object}',
          () {
        final assignment = Assignment(
          isCompleted: true,
          name: 'N',
          description: null,
          subject: null,
          dueDate: null,
          withDueTime: null,
          notes: null,
        );
        final toJSONed = assignment.toJSON();
        final fromJSONed = Assignment.fromJSON(toJSONed);

        expect(fromJSONed, assignment);
      });
    });

    group('(Reminder)', () {
      group('(LocationReminderTrigger)', () {
        test('[toJSON then fromJSON, All fields non-null] {Return same object}',
            () {
          final trigger = LocationReminderTrigger(
            geofenceEvent: GeofenceEvent.enter,
            region: LocationReminderRegion(
              radius: 100,
              location: LocationReminderLocation(
                latitude: 123.456,
                longitude: 2.0,
              ),
            ),
          );

          final json = trigger.toJSON();
          final fromJSONed = LocationReminderTrigger.fromJSON(json);

          expect(trigger, fromJSONed);
        });
        test('[toJSON then fromJSON, region is null] {Return same object}', () {
          final trigger = LocationReminderTrigger(
            geofenceEvent: GeofenceEvent.exit,
            region: null,
          );

          final json = trigger.toJSON();
          final fromJSONed = LocationReminderTrigger.fromJSON(json);

          expect(trigger, fromJSONed);
        });
      });
      group('(LocationReminderRegion)', () {
        test('[toJSON then fromJSON] {Return same object}', () {
          final region = LocationReminderRegion(
            radius: 100,
            location: LocationReminderLocation(
              latitude: 123.456,
              longitude: 2.0,
            ),
          );

          final json = region.toJSON();
          final fromJSONed = LocationReminderRegion.fromJSON(json);

          expect(region, fromJSONed);
        });
      });
      group('(LocationReminderLocation)', () {
        test('[toJSON then fromJSON] {Return same object}', () {
          final location = LocationReminderLocation(
            latitude: 123.456,
            longitude: 2.0,
          );

          final json = location.toJSON();
          final fromJSONed = LocationReminderLocation.fromJSON(json);

          expect(location, fromJSONed);
        });
        test('[saved locatoins toJSON then fromJSON] {Return same object}', () {
          final locations = {
            LocationReminderLocation(latitude: 123.456, longitude: 2.0): 'L1',
            LocationReminderLocation(latitude: 0, longitude: 0): 'L2',
            LocationReminderLocation(latitude: -34, longitude: -50): 'L3',
          };

          final toJSONed =
              LocationReminderLocation.savedLocationsToJSON(locations);
          final fromJSONed =
              LocationReminderLocation.savedLocationsFromJSON(toJSONed);

          expect(fromJSONed.length, locations.length);
          for (var key in fromJSONed.keys) {
            expect(fromJSONed[key], locations[key]);
          }
        });
      });
      group('(TimeReminderRepeat)', () {
        test('[toJSON then fromJSON, day, month and year] {Return same object}',
            () {
          for (TimeReminderRepeat repeat in [
            TimeReminderRepeat.day,
            TimeReminderRepeat.month,
            TimeReminderRepeat.year,
          ]) {
            expect(TimeReminderRepeat.fromJSON(repeat.toJSON()), repeat);
          }
        });
        test(
            '[toJSON then fromJSON, weekDay and timetableDay] {Return same object}',
            () {
          for (TimeReminderRepeat repeat in [
            TimeReminderRepeat.weekDay(7),
            TimeReminderRepeat.timetableDay(TimetableWeekDay(3)),
            TimeReminderRepeat.timetableDay(TimetableCycleDay(3)),
          ]) {
            expect(TimeReminderRepeat.fromJSON(repeat.toJSON()), repeat);
          }
        });
      });
      group('(TimeReminderTrigger)', () {
        test('[toJSON then fromJSON, all fields non-null] {Return same object}',
            () {
          final trigger = TimeReminderTrigger(
            dateTime: DateTime(2020, 2, 29, 15, 05),
            repeat: TimeReminderRepeat.timetableDay(TimetableCycleDay(3)),
          );

          expect(TimeReminderTrigger.fromJSON(trigger.toJSON()), trigger);
        });
        test('[toJSON then fromJSON, id and repeat null] {Return same object}',
            () {
          final trigger = TimeReminderTrigger(
            dateTime: DateTime(2020, 2, 29, 15, 05),
            repeat: null,
          );

          expect(TimeReminderTrigger.fromJSON(trigger.toJSON()), trigger);
        });
      });
      group('(Reminder)', () {
        test('[toJSON then fromJSON, all fields non-null] {Return same object}',
            () {
          final reminder1 = Reminder(
            id: 234234,
            name: 'N',
            enabled: false,
            subject: Subject('S', color: Color(0x12345678)),
            trigger: TimeReminderTrigger(
              dateTime: DateTime(2020, 2, 29, 15, 05),
              repeat: TimeReminderRepeat.day,
            ),
            notes: 'N',
          );

          expect(Reminder.fromJSON(reminder1.toJSON()), reminder1);

          final reminder2 = Reminder(
            id: 234234,
            name: 'N',
            enabled: false,
            subject: Subject('S', color: Color(0x12345678)),
            trigger: LocationReminderTrigger(
              region: LocationReminderRegion(
                location: LocationReminderLocation(
                  latitude: 100,
                  longitude: 12.3456,
                ),
                radius: 30,
              ),
              geofenceEvent: GeofenceEvent.enter,
            ),
            notes: 'N',
          );

          expect(Reminder.fromJSON(reminder2.toJSON()), reminder2);
        });
        test(
            '[toJSON then fromJSON, subject, trigger and notes null] {Return same object}',
            () {
          final reminder = Reminder(
            id: 234234,
            name: 'N',
            enabled: true,
            subject: null,
            trigger: null,
            notes: null,
          );

          expect(Reminder.fromJSON(reminder.toJSON()), reminder);
        });
      });
    });
  });
}
