import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schooler/lib/cycle_config.dart';
import 'package:schooler/lib/settings.dart';

final R = Resources();

class Resources {
  final calendarType = CalendarTypeScreenResources();
  final cyclesEditor = CyclesEditorResources();
  final editText = EditTextResources();
}

class CalendarTypeScreenResources {
  final appBarTitle = 'Calendar Type';
  final padding = const EdgeInsets.all(16.0);
  final buttonTextForTypes = {
    CalendarType.week: 'By Weeks',
    CalendarType.cycle: 'By Cycles',
  };
}

class CyclesEditorResources {
  final defaultCycleConfig = CycleConfig(
    startSchoolYear: DateTime.utc(DateTime.now().year, 9, 1),
    endSchoolYear: DateTime.utc(DateTime.now().year + 1, 7, 31),
    noOfDaysInCycle: 6,
    isSaturdayHoliday: true,
    isSundayHoliday: true,
    holidays: [],
    occasions: [],
  );
  final fadeDuration = const Duration(milliseconds: 250);

  final getCalendarDayTextTheme =
      (BuildContext context) => Theme.of(context).textTheme.body1;
  final calendarHolidayColor = Colors.red;
  final getCalendarDayInfoTextTheme =
      (BuildContext context) => Theme.of(context).textTheme.caption;
  final calendarStartColor = const Color(0xFFB5F0A5);
  final calendarEndColor = const Color(0xFFF0A5A5);
  final outsideMonthColor = const Color(0x44000000);

  final appBarTitle = 'Cycles Editor';

  final doneButtonText = 'Done';
  final dateOptionIcon = Icons.date_range;
  final dateOptionEditIcon = Icons.edit;
  final dateOptionDateFormat = DateFormat('dd MMMM yyyy');
  final textOptionIcon = Icons.text_fields;
  final textOptionEditIcon = Icons.edit;
  final eventTitleDateFormat = DateFormat('dd MMM');
  final eventTitleIcon = Icons.date_range;
  final eventIcon = Icons.event;
  final eventEditIcon = Icons.edit;
  final eventDeleteIcon = Icons.delete;
  final eventNameText = 'Name';
  final eventStartText = 'From';
  final eventEndText = 'To';
  final eventSkipDayText = 'Skip Day';
  final addEventIcon = Icons.add;
  final startSchoolYearOptionText = 'Start of School Year';
  final endSchoolYearOptionText = 'End of School Year';
  final saturdayHolidayOptionText = 'Is Saturday Holiday';
  final sundayHolidayOptionText = 'Is Sunday Holiday';
  final noOfDaysInCycleOptionText = 'Number of Days in a Cycle';
  final holidaysOptionText = 'Holiday';
  final addHolidayText = 'Add Holiday';
  final newHolidayName = 'New Holiday';
  final newHolidaySkipDay = true;
  final occasionsOptionText = 'Occasions';
  final addOccasionText = 'Add Occasion';
  final newOccasionName = 'New Occasion';
  final newOccasionSkipDay = false;

  final selectionCloseIcon = Icons.close;
  final selectionMessagePadding = const EdgeInsets.all(16.0);
  final getSelectionMessage =
      (String fieldName) => 'Select "$fieldName" on the calendar.';
  final selectionCancelText = 'Cancel';
}

class EditTextResources {
  final cancelIcon = Icons.clear;
  final cancelText = 'Clear';
  final doneIcon = Icons.done;
  final doneText = 'Done';
  final textFieldPadding =
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  final clearButtonIcon = Icons.clear;
  final clearButtonTooltip = 'Clear';
}
