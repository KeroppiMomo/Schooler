import 'package:flutter_test/flutter_test.dart';
import 'package:schooler/lib/cycle_config.dart';
import 'package:schooler/lib/settings.dart';

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
  });
}
