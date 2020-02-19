import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/lib/subject.dart';

final R = Resources();

class Resources {
  final sessionTextStyle = TextStyle(fontWeight: FontWeight.bold);
  final placeholderTextStyle = TextStyle(color: Colors.grey);

  final timetableEditor = TimetableEditorResources();

  final setupWelcomeScreen = SetupWelcomeScreenResources();
  final calendarType = CalendarTypeScreenResources();
  final calendarEditor = CalendarEditorResources();
  final editText = EditTextResources();
  final timetableEditorScreen = TimetableEditorScreenResources();
  final subjectEditorScreen = SubjectEditorScreenResources();
  final setupCompletedScreen = SetupCompletedScreenResources();
}

class TimetableEditorResources {
  final listPadding = EdgeInsets.all(16.0);
  final addSessionButtonText = 'Add Session';
  final addSessionButtonIcon = Icons.add;

  final removeTimetableText = 'Remove This Timetable';
  final removeTimetableIcon = Icons.delete;

  String getCopyTimeSlotsText(String dayName) =>
      'Copy Time Slots from $dayName';
  final copyTimeSlotsIcon = Icons.content_copy;

  String Function(TimetableDay) get dayTabName =>
      R.timetableEditorScreen.dayTabName;

  final listItemsSizeTransitionCurve = Curves.easeInOut;

  final sessionEditIcon = Icons.edit;
  final sessionEditIconSize = 16.0;
  final sessionEditIconColor = Colors.grey;

  final sessionDeleteIcon = Icons.delete;
  final sessionDeleteIconSize = 16.0;
  final sessionDeleteIconColor = Colors.grey;

  final sessionEditRegionPadding = const EdgeInsets.all(8.0);
  final sessionEditRegionWidgetsSpacing = 4.0;

  final sessionPadding = const EdgeInsets.symmetric(vertical: 4.0);
  final sessionTimeFormat = DateFormat('HH:mm');
  final sessionTimeWidth = 40.0;
  final sessionTimeTo = '–'; // Text between the start time and end time

  final sessionNoNameText = 'No Name';

  final suggestionMinItemForListView = 4;
  final suggestionListViewHeight = 195.0;
}

class SetupWelcomeScreenResources {
  final padding = EdgeInsets.symmetric(horizontal: 64.0);

  final icon = Icons.school;
  final iconShadowColor = Colors.grey.withOpacity(0.5);

  final itemSpacing = 16.0;

  TextStyle getTitleTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.title;
  final titleText = 'Welcome to Schooler!';
  TextStyle getMessageTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subhead;
  final messageText = 'Help you easily manage your school life.';
  Color getButtonSplashColor(BuildContext context) =>
      Theme.of(context).primaryColor.withOpacity(0.2);
  final buttonText = 'Get Started';
}

class CalendarTypeScreenResources {
  final appBarTitle = 'Calendar Type';
  final padding = const EdgeInsets.all(16.0);
  final buttonTextForTypes = {
    CalendarType.week: 'By Weeks',
    CalendarType.cycle: 'By Cycles',
  };
}

class CalendarEditorResources {
  final defaultCycleConfig = CycleConfig(
    startSchoolYear: DateTime.utc(DateTime.now().year, 9, 1),
    endSchoolYear: DateTime.utc(DateTime.now().year + 1, 7, 31),
    noOfDaysInCycle: 6,
    isSaturdayHoliday: true,
    isSundayHoliday: true,
    holidays: [],
    occasions: [],
  );
  final defaultWeekConfig = WeekConfig(
    startSchoolYear: DateTime.utc(DateTime.now().year, 9, 1),
    endSchoolYear: DateTime.utc(DateTime.now().year + 1, 7, 31),
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

  final cyclesAppBarTitle = 'Cycles Editor';
  final weeksAppBarTitle = 'Weeks Editor';

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
  final cancelText = 'Cancel';
  final doneIcon = Icons.done;
  final doneText = 'Done';
  final textFieldPadding =
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  final clearButtonIcon = Icons.clear;
  final clearButtonTooltip = 'Clear';
}

class TimetableEditorScreenResources {
  final appBarTitle = 'Timetable';

  final popConfirmTitle = 'Discard Timetable';
  final popConfirmMessage =
      'Are you sure to discard the timetable and return to the previous page?';
  final popConfirmCancelText = 'CANCEL';
  final popConfirmDiscardText = 'DISCARD AND RETURN';

  String weekDayTabName(int weekDay) => {
        1: 'Mon',
        2: 'Tue',
        3: 'Wed',
        4: 'Thu',
        5: 'Fri',
        6: 'Sat',
        7: 'Sun',
      }[weekDay];
  String cycleDayTabName(int cycleDay) => 'Day $cycleDay';

  String dayTabName(TimetableDay day) {
    // Also used in R.timetableEditor.dayTabName
    if (day is TimetableWeekDay)
      return weekDayTabName(day.dayOfWeek);
    else if (day is TimetableCycleDay)
      return cycleDayTabName(day.dayOfCycle);
    else if (day is TimetableOccasionDay)
      return day.occasionName;
    else {
      assert(false, 'Unexpected TimetableDay subtype');
      return day.toString();
    }
  }

  final addTabIcon = Icons.add;

  final doneButtonText = 'Done';

  final sessionDefaultStartTime = DateTime(1970, 1, 1, 08, 00);
  final sessionDefaultDuration = Duration(minutes: 35);

  final addTabButtonsCardPadding = EdgeInsets.only(top: 8.0);
  TextStyle getAddTabButtonsCardTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.body1.copyWith(color: Colors.grey);
  final addTabButtonsIcon = Icons.add;

  final addTabNoEventMessage =
      'No available events. All holidays and occasions are with a timetable.';
  TextStyle getAddTabNoEventTextStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .body1
      .copyWith(color: Colors.grey, fontStyle: FontStyle.italic);

  final addTabWidgetSpacing = 16.0; // Spacing between each widgets in ListView

  final addTabButtonsText = 'Add a timetable for any of the following events.';
  final addTabOccasionButtonsTitle = 'Occasions';
  final addTabHolidaysButtonsTitle = 'Holidays';
  final addTabInputNameText =
      'Or add a timetable with a name. \nThe timetable will apply to holidays or occasions with matching name.';
  final addTabInputNameTextFieldLabel = 'Name';
  final addTabInputNameButtonIcon = Icons.add;

  String getAddTabInputNameExistMessage(String name) =>
      'Timetable with name "$name" already exists.';
}

class SubjectEditorScreenResources {
  final popConfirmTitle = 'Discard Subjects';
  final popConfirmMessage =
      'Are you sure to discard the subjects and return to the previous page?';
  final popConfirmCancelText = 'CANCEL';
  final popConfirmDiscardText = 'DISCARD AND RETURN';

  final appBarTitle = 'Subjects';

  final listPadding = EdgeInsets.all(16.0);
  final addSubjectText = 'Add Subject';
  final addSubjectIcon = Icons.add;

  final doneButtonText = 'Done';

  final subjectIcon = Icons.book;
  final subjectPlaceholderText = 'No Name';
  final colorButtonIcon = Icons.palette;
  final colorButtonTooltip = 'Change Color';

  String getColorPickerTitle(String subjectName) =>
      'Select color for "$subjectName"';

  final removeSubjectIcon = Icons.delete;
  final removeSubjectTooltip = 'Remove Subject';

  final removeSubjectSizeTransitionCurve = Curves.easeInOut;

  final colorPickerCancelText = 'CANCEL';

  Subject get defaultNewSubject => Subject('', color: Colors.grey);

  final suggestionMinItemForListView = 4;
  final suggestionListViewHeight = 195.0;

  String getSubjectNameExistMessage(String name) =>
      'Subject with name "$name" already exists.';
}

class SetupCompletedScreenResources {
  final padding = EdgeInsets.symmetric(horizontal: 64.0);

  final icon = Icons.done;
  final iconShadowColor = Colors.grey.withOpacity(0.5);

  final itemSpacing = 16.0;

  TextStyle getTitleTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.title;
  final titleText = 'Setup Completed';
  TextStyle getMessageTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subhead;
  final messageText = 'You can always change these settings later.';
  Color getButtonSplashColor(BuildContext context) =>
      Theme.of(context).primaryColor.withOpacity(0.2);
  final buttonText = 'Done';
}
