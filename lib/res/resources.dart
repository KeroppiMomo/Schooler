import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/geofencing.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/ui/main_tabs/assignments_tab.dart';
import 'package:schooler/ui/main_tabs/today_tab.dart';
import 'package:schooler/ui/main_tabs/calendar_tab.dart';
import 'package:schooler/ui/list_screen.dart';

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

  final listScreen = ListScreenResources();

  final assignmentScreen = AssignmentScreenResources();
  final assignmentDayScreen = AssignmentDayScreenResources();
  final assignmentListScreen = AssignmentListScreenResources();

  final reminderScreen = ReminderScreenResources();
  final remindersListScreen = RemindersListScreenResources();

  final timetableScreen = TimetableScreenResources();

  final suggestionTextField = SuggestionTextFieldResources();
  final regionPicker = RegionPickerResources();
  final locationScreen = LocationScreenResources();
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
      Theme.of(context).textTheme.bodyText1;
}

class SetupWelcomeScreenResources {
  final padding = EdgeInsets.symmetric(horizontal: 64.0);

  final icon = Icons.school;
  final iconShadowColor = Colors.grey.withOpacity(0.5);

  final itemSpacing = 16.0;

  TextStyle getTitleTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.headline6;
  final titleText = 'Welcome to Schooler!';
  TextStyle getMessageTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;
  final messageText = 'Help you easily manage your school life.';
  Color getButtonSplashColor(BuildContext context) =>
      Theme.of(context).primaryColor.withOpacity(0.2);
  final buttonText = 'Get Started';
}

class CalendarTypeScreenResources {
  final appBarTitle = 'Calendar Type';
  final padding = EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0);

  final headerText = 'Choose your calendar type.';
  TextStyle getHeaderStyle(BuildContext context) =>
      Theme.of(context).textTheme.headline6;
  final headerChoicesSpacing = 16.0;

  final weekTitle = 'By Week';
  final weekDescription = 'Timetable for Monday, Tuesday, etc.';
  final weekImage = AssetImage('lib/res/calendar_type_week_icon.png');

  final weekCycleSpacing = 16.0;
  final cycleTitle = 'By Cycle';
  final cycleDescription = 'Timetable for Day 1, Day 2, etc.';
  final cycleImage = AssetImage('lib/res/calendar_type_cycle_icon.png');

  final cardElevation = 3.0;
  final cardImageSpacing = 32.0;
  final cardImageHeight = 100.0;
  final cardImageTitleSpacing = 32.0;
  TextStyle getTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.headline5;
  final cardTitleDescriptionSpacing = 8.0;
  TextStyle getDescriptionStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;
  final cardDescriptionSpacing = 32.0;
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
    skippedDays: [],
  );
  final defaultWeekConfig = WeekConfig(
    startSchoolYear: DateTime.utc(DateTime.now().year, 9, 1),
    endSchoolYear: DateTime.utc(DateTime.now().year + 1, 7, 31),
    isSaturdayHoliday: true,
    isSundayHoliday: true,
    holidays: [],
    occasions: [],
  );

  final tipOneDayDuration = Duration(seconds: 2);
  final tipMultiDayDuration = Duration(seconds: 4);

  final tipFadeDuration = Duration(milliseconds: 250);

  final getCalendarDayTextTheme =
      (BuildContext context) => Theme.of(context).textTheme.bodyText2;
  final calendarHolidayTextColor = Colors.red;
  final calendarHolidayFillColor = Colors.red.shade50;
  final calendarOccasionFillColor = Colors.grey.shade200;
  final calendarSelectedColor = Colors.black.withOpacity(0.1);
  final getCalendarDayInfoTextTheme =
      (BuildContext context) => Theme.of(context).textTheme.caption;
  final calendarStartColor = const Color(0xFFB5F0A5);
  final calendarEndColor = const Color(0xFFF0A5A5);
  final outsideMonthColor = const Color(0x44000000);

  final cyclesAppBarTitle = 'Cycles Editor';
  final weeksAppBarTitle = 'Weeks Editor';

  final dateFormat = DateFormat('dd MMM');

  final doneButtonText = 'Done';
  final eventNameText = 'Name';

  final optionIcon = Icons.list;
  final addEventOptionIcon = Icons.add;
  final addEventOptionText = 'Add Holiday/Occasion';
  final addEventOptionRightIcon = Icons.chevron_right;
  final saturdayHolidayOptionText = 'Is Saturday Holiday';
  final sundayHolidayOptionText = 'Is Sunday Holiday';
  final noOfDaysInCycleOptionText = 'Number of Days in a Cycle';

  final newHolidayName = 'New Holiday';
  final newOccasionName = 'New Occasion';

  final popupTopSpacing = 16.0;
  TextStyle getPopupDateStyle(BuildContext context) =>
      Theme.of(context).textTheme.headline6;
  String getPopupCycleDescription(String cycleDay, int cycle) =>
      'Day $cycleDay, Cycle $cycle';
  TextStyle getPopupDescriptionStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.grey);
  final popupDescriptionHolidaysSpacing = 8.0;
  final popupHolidayText = 'Holidays';
  final popupOccasionText = 'Occasions';
  TextStyle getPopupEventTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.grey);
  final popupEventsWrapSpacing = 8.0;
  final popupEventsWrapRunSpacing = -8.0;
  final popupEventPadding = EdgeInsets.only(right: 8.0);
  final popupEventAddIcon = Icons.add;
  final popupButtonHeight = 48.0;
  final popupSkipDayText = 'Skip Day in Cycle';
  final popupStartOfYearText = 'Set as Start of School Year';
  final popupEndOfYearText = 'Set as End of School Year';
  final popupAddHolidayText = 'Add Holiday';
  final popupAddOccasionText = 'Add Occasion';
  String getPopupRangeDescription(DateTimeRange range) =>
      '${dateFormat.format(range.start)} – ${dateFormat.format(range.end)}';
  final popupNoOptionBottomSpacing = 8.0;

  final addEventPopupOneText = 'Add One-Day Event';
  final addEventPopupMultiText = 'Add Multi-Day Event';

  final tipElevation = 10.0;
  final tipPadding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
  final tipOneDayText = 'Tap a date on the calendar.';
  final tipMultiDayText = 'Hold and drag between two dates on the calendar.';
  final tipCircleBorderColor = Colors.black54;
  final tipCircleFillColor = Colors.grey;
  TextStyle getTipStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;
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
    // Also used in R.timetableEditor.dayTabName, R.timetableWWidget.dayDisplayName, and R.reminderScreen.timeRepeatToString
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
      Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey);
  final addTabButtonsIcon = Icons.add;

  final addTabNoEventMessage =
      'No available events. All holidays and occasions are with a timetable.';
  TextStyle getAddTabNoEventTextStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyText2
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

  final emptyStatesAnimationDuration = Duration(milliseconds: 250);
  final emptyStatesPadding = EdgeInsets.all(32.0);
  final emptyStatesIconSize = 100.0;
  final emptyStatesIconTitleSpacing = 32.0;
  final emptyStatesTitle = 'No Subjects';
  TextStyle getEmptyStatesTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.headline5;
  final emptyStatesTitleDescriptionSpacing = 8.0;
  final emptyStatesDescription =
      'Categorize your assignments and other things into subjects.';
  TextStyle getEmptyStatesDescriptionStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;
  final emptyStatesDescriptionBUttonSpacing = 32.0;

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
      Theme.of(context).textTheme.headline6;
  final titleText = 'Setup Completed';
  TextStyle getMessageTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;
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
      .headline5
      .copyWith(fontWeight: FontWeight.bold);
  TextStyle getDayDescriptionTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;

  final dayWWidgetsSpacing = 16.0;
}

class AssignmentsTabResources {
  final switchViewDuration = const Duration(milliseconds: 200);
}

class WWidgetResources {
  final titleItemsSpacing = 16.0;
  final titleIconSize = 20.0;
  TextStyle titleTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.subtitle1;
  final titleActionIconPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  final settingsIcon = Icons.settings;
  final refreshIcon = Icons.refresh;
  final contentPadding = EdgeInsets.all(16.0);
}

class TimetableWWidgetResources {
  final timestampFormat = DateFormat('hh:mm');
  TextStyle currentTimestampTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText2.copyWith(
          fontWeight: FontWeight.bold, decoration: TextDecoration.underline);
  TextStyle afterTimestampTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText2;
  TextStyle beforeTimestampTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey);

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
  String getViewText(int noOfReminders) => 'View All $noOfReminders Reminders';

  // Referenced from R.remindersListScreen
  final timeReminderNullText = 'No Date Selected';
  final locationReminderNullText = 'No Location Selected';
  final reminderNoTriggerText = 'No Trigger';
  final reminderGeofenceEventString = {
    GeofenceEvent.enter: 'When Enter ',
    GeofenceEvent.exit: 'When Exit ',
  };
  String reminderLatLongFormat(double lat, double long) => '($lat, $long)';
  final reminderDateFormat = DateFormat("'At' dd MMM HH:mm");

  final reminderTriggerIcon = {
    LocationReminderTrigger: Icons.location_on,
    TimeReminderTrigger: Icons.alarm,
  };
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

class ListScreenResources {
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

  final refreshDelay = const Duration(milliseconds: 500);
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

  final goToTodayDuration = const Duration(milliseconds: 400);
  final goToTodayCurve = Curves.easeInOut;
  final goToTodayAlignment = 0.2;

  final dayDividerHeight = 32.0;
  final dayDividerIndent = 90.0;

  final dayDayOfWeekFormat = DateFormat('EEE');
  String dayCycleDayFormat(String cycleDay) => 'Day $cycleDay';
  String dayCycleFormat(int cycle) => 'Cycle $cycle';

  final dayWidth = 90.0;

  final startEndMessagePadding = EdgeInsets.symmetric(vertical: 48.0);
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
}

class ReminderScreenResources {
  final appBarTitle = 'Reminder';
  final deleteIcon = Icons.delete;
  final deleteTooltip = 'Delete Reminder';

  final listViewPadding =
      EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);

  final reminderIcon = Icons.notifications;
  final reminderIconSize = 32.0;

  final iconColor = Colors.black54;

  TextStyle getNameTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.headline5;
  final nameHintText = 'Name';
  final nameEnabledSpacing = 4.0;

  final enabledText = 'Enabled';
  final enabledSubjectSpacing = 16.0;

  final subjectIcon = Icons.book;
  final subjectHeight = 32.0;
  final subjectPlaceholderPadding = EdgeInsets.all(4.0);
  final subjectPlaceholder = 'Add Subject';
  TextStyle subjectPlaceholderTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black54);
  final subjectBlockEditSpacing = 4.0;
  final subjectEditIcon = Icons.edit;
  final subjectIconColor = Colors.grey;
  final subjectEditRemoveSpacing = 4.0;
  final subjectRemoveIcon = Icons.delete;
  final subjectTriggerSpacing = 16.0;

  final triggerTypeVerticalSpacing = -8.0;
  final triggerTypeHorizontalSpacing = 4.0;
  final triggerTypeIconSize = 20.0;
  final triggerTypeNullText = 'No Trigger';
  final triggerTypeTimeIcon = Icons.alarm;
  final triggerTypeTimeText = 'Time-based Trigger';
  final triggerTypeLocationIcon = Icons.place;
  final triggerTypeLocationText = 'Location-based Trigger';
  final triggerTypeOptionsSpacing = 4.0;

  final triggerOptionsSwitchDuration = Duration(milliseconds: 300);
  final triggerOptionsSwitchCurve = Curves.easeOut;
  final triggerOptionsNotesSpacing = 16.0;

  final notesIcon = Icons.subject;
  final notesPadding = EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0);
  final notesPlaceholder = 'Add Notes';
  TextStyle getNotesPlaceholderTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black54);

  final iconColumnWidth = 48.0;

  final timeOptionsDateTimeHeight = 32.0;
  final timeOptionsDateTimePlaceholderPadding = EdgeInsets.all(4.0);
  final timeOptionsDateTimePlaceholder = 'Select Date and Time';
  TextStyle getTimeOptionsDateTimePlaceholderTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black54);
  final timeOptionsDatePadding = EdgeInsets.all(4.0);
  final timeOptionsDateFormat = DateFormat('dd MMM');
  final timeOptionsTimePadding = EdgeInsets.all(4.0);
  final timeOptionsTimeFormat = DateFormat('HH:mm');
  final timeOptionsTimeEditSpacing = 4.0;
  final timeOptionsEditIcon = Icons.edit;
  final timeOptionsEditIconColor = Colors.grey;
  final timeOptionsRepeatSpacing = 8.0;

  final timeRepeatIcon = Icons.repeat;
  final timeRepeatHeight = 32.0;
  final timeRepeatPadding = EdgeInsets.all(4.0);
  final timeRepeatPlaceholder = 'Add Repeat';
  TextStyle getTimeRepeatPlaceholderTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black54);
  String timeRepeatTimeToString(TimeReminderRepeat repeat) {
    if (repeat == TimeReminderRepeat.day) return 'Daily';
    if (repeat == TimeReminderRepeat.month) return 'Monthly';
    if (repeat == TimeReminderRepeat.year) return 'Yearly';
    if (repeat.getWeekDay() != null) {
      final weekDayString = {
        1: 'Monday',
        2: 'Tuesday',
        3: 'Wednesday',
        4: 'Thursday',
        5: 'Friday',
        6: 'Saturday',
        7: 'Sunday',
      };
      return 'Every ${weekDayString[repeat.getWeekDay()]}';
    } else if (repeat.getTimetableDay() != null) {
      return 'Every ${R.timetableEditor.dayTabName(repeat.getTimetableDay())}';
    } else {
      assert(false, 'Unexpected TimeReminderRepeat value');
      return '';
    }
  }

  final timeRepeatEditIcon = Icons.edit;
  final timeRepeatEditIconColor = Colors.grey;

  final geofenceEventName = {
    GeofenceEvent.enter: 'Enter',
    GeofenceEvent.exit: 'Exit',
  };
  final locationOptionsHeight = 32.0;
  final locationOptionsPadding = EdgeInsets.all(4.0);
  final locationOptionsPlaceholder = 'Select Location';
  TextStyle getLocationOptionsPlaceholderTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black54);
  String getLocationOptionsText(
          String geofenceEventString, String locationDescription) =>
      'When $geofenceEventString $locationDescription';
  final locationOptionsEditIcon = Icons.edit;
  final locationOptionsEditIconColor = Colors.grey;

  final subjectPickerMinItemForListView = 4;
  final subjectPickerListViewHeight = 195.0;

  final repeatPickerCancelPressedOpacity = 0.3;
  final repeatPickerCancelPadding = EdgeInsets.symmetric(horizontal: 16.0);
  final repeatPickerCancelText = 'Cancel';
  final repeatPickerCancelTextStyle =
      TextStyle(color: Colors.black54, fontSize: 16.0);
  final repeatPickerChoicesText = {
    null: 'No Repeat',
    TimeReminderRepeat.day: 'Daily',
    TimeReminderRepeat.weekDay(1): 'Every Week',
    TimeReminderRepeat.timetableDay(TimetableCycleDay(1)): 'Every Cycle',
    TimeReminderRepeat.month: 'Monthly',
    TimeReminderRepeat.year: 'Yearly',
  };
  final repeatPickerArrowIcon = Icons.chevron_right;
  final repeatPickerWeekdayText = [
    'Every Monday',
    'Every Tuesday',
    'Every Wednesday',
    'Every Thursday',
    'Every Friday',
    'Every Saturday',
    'Every Sunday',
  ];
  String Function(TimetableDay) get timetableDayToString =>
      R.timetableEditor.dayTabName;

  String getNotesURLError(String url) =>
      'Failed to open $url. Check whether the URL is correct.';
  final notesEditTextScreenTitle = 'Notes';
  final deleteTitle = 'Delete Reminder?';
  final deleteContent = 'This action cannot be undone.';
  final deleteCancelText = 'CANCEL';
  final deleteConfirmText = 'DELETE';

  final geofenceErrorConfirmText = 'GOT IT';
  final geofenceErrorPermissionTitle = 'Could not access your location';
  final geofenceErrorPermissionContent =
      'Location-based reminders require "Always"/"All the time" location permission. \nGo to Settings to change the permission.';
  final geofenceErrorPermissionSettingsText = 'TURN ON LOCATION';
  final geofenceErrorUnavailableTitle =
      'Location-based reminders are unavailable';
  final geofenceErrorUnavailableContent =
      'Try turning on location services, or checking whether your device supports geofencing.';
  final geofenceErrorRadiusTitle = 'Region radius is too large';
  final geofenceErrorRadiusContent = 'Try a smaller region radius.';
  final geofenceErrorGeofencesNoTitle = 'Too many location-based reminders';
  final geofenceErrorGeofencesNoContent =
      'The number of location-based reminders has exceeded the limit of your device.\nTry disabling other location-based reminders.';
  final geofenceUnknownTitle = 'Unknown error occurred';
}

class RemindersListScreenResources {
  final appBarTitle = 'Reminders';
  final addFABTooltip = 'Add Reminder';
  final addFABIcon = Icons.add;

  final Map<String, Comparable Function(Reminder)> reminderSorts = {
    'Enabled': (r) => r.enabled ? 1 : 0,
    'Name': (r) => r.name,
    'Subject': (r) => r.subject?.name ?? '',
    'Trigger': (r) => (r.trigger is TimeReminderTrigger ? 'Time-based Trigger' : (r.trigger is LocationReminderTrigger ? 'Location-based Trigger' : '')),
  };
  MapEntry<String, Comparable Function(Reminder)> get defaultSorting =>
      reminderSorts.entries.toList()[0];
  final defaultSortDirection = SortDirection.ascending;

  final noSortText = 'Creation Date';

  String get timeReminderNullText => R.remindersWWidget.timeReminderNullText;
  String get locationReminderNullText => R.remindersWWidget.locationReminderNullText;
  String get reminderNoTriggerText => R.remindersWWidget.reminderNoTriggerText;
  Map<GeofenceEvent, String> get reminderGeofenceEventString => R.remindersWWidget.reminderGeofenceEventString;
  DateFormat get reminderDateFormat => R.remindersWWidget.reminderDateFormat;

  Map<Type, IconData> get reminderTriggerIcon => R.remindersWWidget.reminderTriggerIcon;
  double get reminderDisabledOpacity => R.remindersWWidget.reminderDisabledOpacity;
  final reminderPadding = EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0);

  double get reminderIconColumnWidth => R.remindersWWidget.reminderIconColumnWidth;
  EdgeInsets get reminderIconPadding => R.remindersWWidget.reminderIconPadding;
  IconData get reminderIconEnable => R.remindersWWidget.reminderIconEnable;
  IconData get reminderIconDisabled => R.remindersWWidget.reminderIconDisabled;
  double get reminderIconSize => R.remindersWWidget.reminderIconSize;

  TextStyle reminderTitleTextStyle(BuildContext context) =>
      R.remindersWWidget.reminderTitleTextStyle(context);
  double get reminderSubjectTitleSpacing => R.remindersWWidget.reminderSubjectTitleSpacing;
  MaterialColor get reminderTriggerIconColor => R.remindersWWidget.reminderTriggerIconColor;
  double get reminderTriggerIconSize => R.remindersWWidget.reminderTriggerIconSize;
  double get reminderTriggerIconTextSpacing => R.remindersWWidget.reminderTriggerIconTextSpacing;
  TextStyle reminderTriggerTextStyle(BuildContext context) =>
      R.remindersWWidget.reminderTriggerTextStyle(context);

  /// Each reminder is turned into a [String] when a search is performed.
  /// The time-based dateTime is formated according to this format.
  final searchDateTimeFormat = DateFormat('dd MMMM HH:mm');
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

class SuggestionTextFieldResources {
  final dateFormat = DateFormat('dd MMM');
  final dateCancelOpacity = 0.3;
  final dateCancelPadding = EdgeInsets.symmetric(horizontal: 16.0);
  final dateCancelText = 'Cancel';
  final dateCancelTextStyle =
      const TextStyle(color: Colors.black54, fontSize: 16.0);
  final dateChoiceIcon = Icons.today;
  final dateChoiceTrailing = Icons.navigate_next;
  final dateTodayText = 'Today';
  final dateTomorrowText = 'Tomorrow';
  final dateMondayText = 'Monday';
  String getDateSubjectSession(String subject) => 'Next $subject Session';
}

class RegionPickerResources {
  LocationReminderTrigger get defaultTrigger => LocationReminderTrigger(
        region: LocationReminderRegion(
          location: LocationReminderLocation(
            latitude: 22.3220112,
            longitude: 114.1678075,
          ),
          radius: 100,
        ),
        geofenceEvent: GeofenceEvent.enter,
      );
  final defaultZoomLevel = 17.0;

  final headerButtonPressedOpacity = 0.3;
  final headerButtonPadding = EdgeInsets.symmetric(horizontal: 16.0);
  final cancelButtonText = 'Cancel';
  final cancelButtonTextStyle =
      TextStyle(color: Colors.black54, fontSize: 16.0);
  final doneButtonText = 'Done';
  final doneButtonTextStyle = TextStyle(color: Colors.blue, fontSize: 16.0);

  final optionTitleWidth = 110.0;
  final optionTitleContentSpacing = 8.0;

  final geofenceEventTitle = 'Trigger When';
  final geofenceEnterText = 'Enter Region';
  final geofenceExitText = 'Exit Region';

  final radiusTitle = 'Region Radius';
  final radiusSliderMin = 100;
  final radiusSliderMax = 10000;
  final radiusSliderStep = 50;
  final radiusTextFieldWidth = 50.0;
  final radiusUnitText = ' m';

  final locationTitle = 'Location';
  final locationNewLocationText = 'New Location';
  final locationRenameIcon = Icons.edit;
  final locationRenameTooltip = 'Rename Location';

  final mapHeight = 230.0;
  final mapRegionFilledColor = Colors.blue.withOpacity(0.2);
  final mapRegionBorderColor = Colors.blue;
  final mapRegionBorderWidth = 2.0;
  final mapPinSize = 50.0;
  double get mapMyLocationMarginRight => Platform.isAndroid ? 64.0 : 16.0;
  final mapMyLocationMarginBottom = 16.0;
  final mapMyLocationIcon = Icons.my_location;

  final myLocationFailedTitle = "Could not access your location";
  final myLocationFailedContent =
      "Make sure locations are enabled for this app.";
  final myLocationFailedOKText = "OK";
}

class LocationScreenResources {
  String getNewLocationName(int count) => 'My Location $count';

  final appBarTitle = 'Location';
  final cancelIcon = Icons.clear;
  final cancelText = 'Cancel';
  final doneIcon = Icons.done;
  final doneText = 'Done';

  final instructionPadding = EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0);
  final instructionText = 'Rename this location:';

  final textFieldPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  final textFieldLabelText = 'Location Name';
  final textFieldClearIcon = Icons.clear;
  final textFieldTooltip = 'Clear';

  final removeIcon = Icons.delete;
  final removeText = 'Remove Location';

  final cancelDoneButtonHeight = 40.0;

  final mapDefaultZoom = 16.0;

  final removeAlertTitle = 'Remove Location?';
  final removeAlertContent =
      'This location will not appear in the location list.';
  final removeAlertCancelText = 'CANCEL';
  final removeAlertConfirmText = 'REMOVE';
}
