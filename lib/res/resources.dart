import 'package:flutter/material.dart';
import 'package:geofencing/geofencing.dart';
import 'package:intl/intl.dart';
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/ui/main_tabs/assignments_tab.dart';
import 'package:schooler/ui/main_tabs/today_tab.dart';
import 'package:schooler/ui/main_tabs/calendar_tab.dart';
import 'package:schooler/ui/assignments_list_screen.dart';

final R = Resources();

class Resources {
  final sessionTextStyle = TextStyle(fontWeight: FontWeight.bold);
  final placeholderTextStyle = TextStyle(color: Colors.grey);

  final timetableEditor = TimetableEditorResources();
  final subjectBlock = SubjectBlockResources();

  final setupWelcomeScreen = SetupWelcomeScreenResources();
  final calendarType = CalendarTypeScreenResources();
  final calendarEditor = CalendarEditorResources();
  final editText = EditTextResources();
  final timetableEditorScreen = TimetableEditorScreenResources();
  final subjectEditorScreen = SubjectEditorScreenResources();
  final setupCompletedScreen = SetupCompletedScreenResources();

  final mainScreen = MainScreenResources();
  final todayTab = TodayTabResources();
  final assignmentTab = AssignmentsTabResources();

  final wwidget = WWidgetResources();
  final timetableWWidget = TimetableWWidgetResources();
  final assignmentWWidget = AssignmentWWidgetResources();
  final remindersWWidget = RemindersWWidgetReosurces();

  final assignmentScreen = AssignmentScreenResources();
  final assignmentDayScreen = AssignmentDayScreenResources();
  final assignmentListScreen = AssignmentListScreenResources();

  final timetableScreen = TimetableScreenResources();
}

class TimetableEditorResources {
  final listPadding = EdgeInsets.all(16.0); // Share with R.timetableScreen
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

  // Share with R.timetableScreen
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

class SubjectBlockResources {
  final margin = EdgeInsets.symmetric(vertical: 2.0);
  final textPadding = EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
  TextStyle getTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.body2;
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
  final dismissIcon = Icons.clear;
  final appBarTitle = 'Timetable';

  final popConfirmTitle = 'Discard Timetable';
  final popConfirmMessage =
      'Are you sure to discard the timetable and return to the previous page?';
  final popConfirmCancelText = 'CANCEL';
  final popConfirmDiscardText = 'DISCARD AND RETURN';

  // Share with R.timetableScreen
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
    // Also used in R.timetableEditor.dayTabName and R.timetableWWidget.dayDisplayName
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

class MainScreenResourcesTabInfo {
  final String name;
  final IconData icon;
  final WidgetBuilder builder;

  const MainScreenResourcesTabInfo({this.name, this.icon, this.builder});
}

class MainScreenResources {
  final tabsInfo = [
    MainScreenResourcesTabInfo(
        name: 'Assignments',
        icon: Icons.assignment,
        builder: (_) => AssignmentsTab()),
    MainScreenResourcesTabInfo(
        name: 'Today',
        icon: Icons.assignment_turned_in,
        builder: (_) => TodayTab()),
    MainScreenResourcesTabInfo(
        name: 'Calendar',
        icon: Icons.calendar_today,
        builder: (_) => CalendarTab()),
  ];
}

class TodayTabResources {
  String getDescriptionComponentCycleDay(String cycleDay) => 'Day $cycleDay';
  String getDescriptionComponentCycle(String cycle) => 'Cycle $cycle';

  final descriptionWeekendText = 'Weekend';

  final appBarTitle = 'Today';

  final listViewPadding =
      EdgeInsets.only(left: 16.0, right: 16.0, top: 64.0, bottom: 16.0);

  final dateFormat = DateFormat('dd MMMM yyyy');
  TextStyle getDateTextStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .headline
      .copyWith(fontWeight: FontWeight.bold);
  TextStyle getDayDescriptionTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subhead;

  final dayWWidgetsSpacing = 16.0;
}

class AssignmentsTabResources {
  final switchViewDuration = const Duration(milliseconds: 200);
}

class WWidgetResources {
  final titleItemsSpacing = 16.0;
  final titleIconSize = 20.0;
  TextStyle titleTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subhead;
  final titleActionIconPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  final settingsIcon = Icons.settings;
  final refreshIcon = Icons.refresh;
  final contentPadding = EdgeInsets.all(16.0);
}

class TimetableWWidgetResources {
  final timestampFormat = DateFormat('hh:mm');
  TextStyle currentTimestampTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.body1.copyWith(
          fontWeight: FontWeight.bold, decoration: TextDecoration.underline);
  TextStyle afterTimestampTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.body1;
  TextStyle beforeTimestampTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.body1.copyWith(color: Colors.grey);

  String Function(TimetableDay day) get dayDisplayName =>
      R.timetableEditor.dayTabName;

  final sessionTimeTo = '–'; // Text between the start time and end time

  final wwidgetTitle = 'Timetable';
  final wwidgetIcon = Icons.access_time;

  final columnTimeToWidth = 20.0; // The width of the column of characters '–'
  final timestampNameSpacing =
      8.0; // Spacing between the timestamp and the session name

  final viewTimetableIcon = Icons.remove_red_eye;
  final viewNoTimetableText = 'View Timetable';
  String viewTimetableText(TimetableDay day) =>
      'View Timetable for ${dayDisplayName(day)}';
}

class AssignmentWWidgetResources {
  final wwidgetTitle = 'Assignments';
  final wwidgetIcon = Icons.assignment;
  final wwidgetPadding = EdgeInsets.symmetric(
      vertical: 16.0); // To allow assignments to expand to the edge

  final addAssignmentText = 'Add Assignment';
  final addAssignmentIcon = Icons.add;

  final viewAssignmentsIcon = Icons.remove_red_eye;
  String getViewAssignmentsText(int noOfAssignments) =>
      'View All $noOfAssignments Assignment${noOfAssignments == 1 ? '' : 's'}';

  final completedTextPadding = EdgeInsets.only(bottom: 8.0);
  final completedText = 'All Done!';
  TextStyle getCompletedTextStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyText2
      .copyWith(color: Theme.of(context).primaryColor);

  final dueColorFuture = Colors.grey;
  final dueColorExpired = Colors.red;
  Color getDueColorOneDay(BuildContext context) =>
      Theme.of(context).primaryColor;

  final assignmentPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0);
  final checkboxColumnWidth = 36.0;
  final checkboxSize = 24.0;
  TextStyle getAssignmentNameTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;
  final assignmentSubjectNameSpacing = 4.0;
  TextStyle dueTextStyle(BuildContext context, Color dueColor) =>
      Theme.of(context).textTheme.bodyText2.copyWith(color: dueColor);

  String relativeDueDateString(DateTime now, DateTime dueDate, bool withTime) {
    if (dueDate == null) return 'No Due Date';

    final nowDateOnly = DateTime.utc(now.year, now.month, now.day);
    final dueDateOnly = DateTime.utc(dueDate.year, dueDate.month, dueDate.day);

    final String dateString = () {
      final dayDifference = dueDateOnly.difference(nowDateOnly).inDays;
      if (dayDifference < -1) return '${-dayDifference} Days Ago';
      if (dayDifference == -1) return 'Yesterday';
      if (dayDifference == 0) return 'Today';
      if (dayDifference == 1) return 'Tomorrow';
      if (dayDifference > 1 && dayDifference < 7)
        return DateFormat('EEEE').format(dueDateOnly);
      return DateFormat('dd MMM').format(dueDateOnly);
    }();

    if (withTime) {
      final timeString = DateFormat('HH:mm').format(dueDate);
      return 'Due ' + dateString + ' ' + timeString;
    } else {
      return 'Due ' + dateString;
    }
  }

  final sizeTransitionCurve = Curves.easeInOut;

  final completionRemovalDelay = const Duration(seconds: 1);
}

class RemindersWWidgetReosurces {
  final wwidgetTitle = 'Reminders';
  final wwidgetIcon = Icons.notifications;
  final wwidgetPadding = EdgeInsets.symmetric(vertical: 16.0);

  final addIcon = Icons.add;
  final addText = 'Add Reminder';
  final viewIcon = Icons.remove_red_eye;
  final viewText = 'View All 6 Reminders';

  final reminderGeofenceEventString = {
    GeofenceEvent.enter: 'When Enter ',
    GeofenceEvent.exit: 'When Exit ',
  };
  String reminderLatLongFormat(double lat, double long) => '($lat, $long)';
  final reminderDateFormat = DateFormat("'At' dd MMM HH:mm");

  final reminderDisabledOpacity = 0.5;
  final reminderPadding =
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0);

  final reminderIconColumnWidth = 36.0;
  final reminderIconPadding = EdgeInsets.all(2.0);
  final reminderIconEnable = Icons.notifications_active;
  final reminderIconDisabled = Icons.notifications_off;
  final reminderIconSize = 21.0;

  TextStyle reminderTitleTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;
  final reminderSubjectTitleSpacing = 4.0;
  final reminderTriggerIconColor = Colors.grey;
  final reminderTriggerIconSize = 16.0;
  final reminderTriggerIconTextSpacing = 4.0;
  TextStyle reminderTriggerTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey);
}

class AssignmentScreenResources {
  final appBarTitle = 'Assignment';
  final listViewPadding =
      EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
  final iconColumnWidth = 48.0;
  final leftIconColor = Colors.black54;
  final rightIconColor = Colors.grey;
  final checkboxSize = 24.0;
  TextStyle placeholderStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black54);
  final editIcon = Icons.edit;

  final titleHintText = 'Title';
  final descriptionHintText = 'Add Description';
  final descriptionSubjectSpacing = 32.0;
  final subjectIcon = Icons.book;
  final subjectRow = 32.0;
  final subjectPlaceholderPadding = EdgeInsets.all(4.0);
  final subjectPlaceholder = 'Add Subject';
  final subjectRowSpacing = 4.0;
  final subjectRemoveIcon = Icons.delete;
  final subjectDueTypeSpacing = 16.0;
  final dueTypeRunSpacing = -8.0;
  final dueTypeSpacing = 4.0;
  final dueTypeNoDueDate = 'No Due Date';
  final dueTypeDueDate = 'Due Date';
  final dueTypeDueTime = 'Due Time';
  final dueDateAnimationDuration = const Duration(milliseconds: 100);
  final dueDateNotesSpacing = 16.0;
  final notesIcon = Icons.subject;
  final notesPadding = EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0);
  final notesPlaceholder = 'Add Notes';

  final dueDateRowHeight = 32.0;
  final dueDateIcon = Icons.today;
  final dueDateInkWellPadding = EdgeInsets.all(4.0);
  final dueDateFormat = DateFormat('dd MMM');
  final dueTimeFormat = DateFormat('HH:mm');
  final dueDateEditSpacing = 4.0;

  final subjectMinItemForListView = 4;
  final subjectListViewHeight = 195.0;

  final dueDateCancelOpacity = 0.3;
  final dueDateCancelPadding = EdgeInsets.symmetric(horizontal: 16.0);
  final dueDateCancelText = 'Cancel';
  final dueDateCancelTextStyle =
      const TextStyle(color: Colors.black54, fontSize: 16.0);
  final dueDateChoiceIcon = Icons.today;
  final dueDateChoiceTrailing = Icons.navigate_next;
  final dueDateTodayText = 'Today';
  final dueDateTomorrowText = 'Tomorrow';
  final dueDateMondayText = 'Monday';
  String getDueDateSubjectSession(String subject) => 'Next $subject Session';

  String getNotesURLError(String url) =>
      'Failed to open $url. Check whether the URL is correct.';
  final notesEditTextTitle = 'Notes';
}

class AssignmentDayScreenResources {
  final appBarTitle = 'Assignments';
  final goToTodayIcon = Icons.today;
  final goToTodayTooltip = 'Go to Today';
  final switchViewIcon = Icons.list;
  final switchViewTooltip = 'Switch to List View';
  final addFABIcon = Icons.add;
  final addFABTooltip = 'Add Assignment';
  final todayOffset = -100.0;
  final goToTodayDuration = const Duration(milliseconds: 400);
  final goToTodayCurve = Curves.easeInOut;

  final dayDividerHeight = 32.0;
  final dayDividerIndent = 90.0;

  final dayDayOfWeekFormat = DateFormat('EEE');
  String dayCycleDayFormat(String cycleDay) => 'Day $cycleDay';
  String dayCycleFormat(int cycle) => 'Cycle $cycle';

  final dayWidth = 90.0;

  final startReachedMessage = 'Start of School Year Reached.';
  final endReachedMessage = 'End of School Year Reached.';
  TextStyle startEndMessageStyle(BuildContext context) =>
      Theme.of(context).textTheme.headline5;

  final todayCircleSize = 40.0;
  final normalDayColor = Colors.black;
  final holidayDayColor = Colors.red;
  final todayCircleTextColor = Colors.white;
  final occasionTextDecoration = TextDecoration.underline;
  final dayFontWeight = FontWeight.bold;
  TextStyle dayTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.headline5;

  final dayDescriptionSpacing = 8.0;
  final dayDescriptionPadding = EdgeInsets.symmetric(horizontal: 8.0);
  TextStyle dayDescriptionTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText1;

  final addAssignmentPadding =
      EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
  final addAssignmentIcon = Icons.add;
  final addAssignmentColor = Colors.grey;
  final addAssignmentText = 'Add Assignment';
  TextStyle addAssignmentTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.grey);

  final monthHeaderColor = Color(0xFFCCCCCC);
  final monthHeaderPadding =
      const EdgeInsets.only(left: 32.0, right: 32.0, top: 24.0, bottom: 16.0);
  final monthHeaderFormat = DateFormat('MMMM yyyy');
  TextStyle monthHeaderTextStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .headline5
      .copyWith(fontWeight: FontWeight.bold);
  final monthHeaderElevation = 5.0;
  final monthHeaderDaySpacing = 16.0;

  // Same as R.assignmentsListScreen
  final assignmentPadding =
      EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
  final assignmentCheckboxColumnWidth = 36.0;
  final assignmentCheckboxSize = 24.0;
  final assignmentCompletedOpacity = 0.5;
  TextStyle assignmentTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;
  final assignmentTitleSubjectSpacing = 4.0;
  final assignmentDueDateFormat = DateFormat("'Due' HH:mm '|' ");
  TextStyle assignmentDescriptionTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.grey);
}

class AssignmentListScreenResources {
  final Map<String, Comparable Function(Assignment)> assignmentSorts = {
    'Completed': (a) => a.isCompleted ? 1 : 0,
    'Due Date': (a) => a.dueDate?.millisecondsSinceEpoch ?? 0,
    'Name': (a) => a.name,
    'Subject': (a) => a.subject?.name ?? '',
  };
  final noSortText = 'Creation Date';
  MapEntry<String, Comparable Function(Assignment)> get defaultSorting =>
      assignmentSorts.entries.toList()[1];
  final defaultSortDirection = SortDirection.ascending;

  final appBarTitle = 'Assignments';
  final switchViewIcon = Icons.calendar_view_day;
  final switchViewTooltip = 'Switch to Day View';

  final addFABIcon = Icons.add;
  final addFABTooltip = 'Add Assignment';

  final searchBarIcon = Icons.search;
  final searchBarClearIcon = Icons.clear;
  final searchBarClearTooltip = 'Clear Search';
  final searchBarHintText = 'Search';

  final listViewPadding = const EdgeInsets.fromLTRB(24.0, 24.0, 0.0, 24.0);

  final sortText = 'Sort By';
  final sortTextChipsSpacing = 8.0;
  final sortRowHeight = 52.0;
  Color getSortChipSelectedColor(BuildContext context) =>
      Theme.of(context).primaryColor.withOpacity(0.3);
  final sortChipsSpacing = 4.0;
  final sortAscendingIcon = Icons.arrow_drop_up;
  final sortDescendingIcon = Icons.arrow_drop_down;

  // From R.assignmentDayScreen
  EdgeInsets get assignmentPadding => R.assignmentDayScreen.assignmentPadding;
  double get assignmentCheckboxColumnWidth =>
      R.assignmentDayScreen.assignmentCheckboxColumnWidth;
  double get assignmentCheckboxSize =>
      R.assignmentDayScreen.assignmentCheckboxSize;
  double get assignmentCompletedOpacity =>
      R.assignmentDayScreen.assignmentCompletedOpacity;
  TextStyle assignmentTitleStyle(BuildContext context) =>
      R.assignmentDayScreen.assignmentTitleStyle(context);
  double get assignmentTitleSubjectSpacing =>
      R.assignmentDayScreen.assignmentTitleSubjectSpacing;
  final assignmentDueTimeFormat = DateFormat("'Due' dd MMM HH:mm '|' ");
  final assignmentDueDateFormat = DateFormat("'Due' dd MMM '|' ");
  TextStyle assignmentDescriptionTextStyle(BuildContext context) =>
      R.assignmentDayScreen.assignmentDescriptionTextStyle(context);

  /// Each assignment is turned into a [String] when a search is performed.
  /// The due date is formated according to this format.
  final searchDueDateFormat = DateFormat('dd MMMM HH:mm');

  final refreshDelay = const Duration(milliseconds: 500);
}

class TimetableScreenResources {
  final appBarTitle = 'Timetable';
  final editIcon = Icons.edit;
  final editTooltip = 'Edit Timetable';

  // From R.timetableEditorScreen
  String Function(int) get weekDayTabName =>
      R.timetableEditorScreen.weekDayTabName;
  String Function(int) get cycleDayTabName =>
      R.timetableEditorScreen.cycleDayTabName;
  String Function(TimetableDay) get dayTabName =>
      R.timetableEditorScreen.dayTabName;

  final listPadding =
      const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0);
  final sessionPadding = const EdgeInsets.symmetric(vertical: 8.0);

  final sessionTimeNameSpacing = 16.0;

  // From R.timetableEditor
  double get sessionTimeStampSpacing =>
      R.timetableEditor.sessionEditRegionWidgetsSpacing;
  DateFormat get sessionTimeFormat => R.timetableEditor.sessionTimeFormat;
  double get sessionTimeWidth => R.timetableEditor.sessionTimeWidth;
  String get sessionTimeTo => R.timetableEditor.sessionTimeTo;
  String get sessionNoNameText => R.timetableEditor.sessionNoNameText;
}
