import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

abstract class TimePicker extends CommonPickerModel {
  factory TimePicker.normal({DateTime currentTime, LocaleType locale}) =>
      _TimePickerNormal(currentTime: currentTime, locale: locale);
  factory TimePicker.fiveMin({DateTime currentTime, LocaleType locale}) =>
      _TimePicker5Min(currentTime: currentTime, locale: locale);

  TimePicker._({DateTime currentTime, LocaleType locale})
      : super(currentTime: currentTime, locale: locale);
}

class _TimePickerNormal extends TimePicker {
  _TimePickerNormal({DateTime currentTime, LocaleType locale})
      : super._(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(
        0); // Prevent initialItem != null (error from the package)
    this.setRightIndex((this.currentTime.minute).round());
  }

  @override
  String leftStringAtIndex(int index) {
    if (index < 0 || index >= 24) return null;
    return '$index'.padLeft(2, '0');
  }

  @override
  String middleStringAtIndex(int index) {
    if (index != 0) return null;
    return ':';
  }

  @override
  String rightStringAtIndex(int index) {
    if (index < 0 || index >= 60) return null;
    return index.toString().padLeft(2, '0');
  }

  @override
  List<int> layoutProportions() => [5, 1, 5]; // Remove Middle Index

  @override
  DateTime finalTime() {
    return DateTime(
        1970, 1, 1, this.currentLeftIndex(), this.currentRightIndex());
  }
}

class _TimePicker5Min extends TimePicker {
  _TimePicker5Min({DateTime currentTime, LocaleType locale})
      : super._(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(
        0); // Prevent initialItem != null (error from the package)
    this.setRightIndex((this.currentTime.minute / 5)
        .round()); // The TimePicker5Min only shows minute which is divisible by 5, ie 0, 5, 10 etc.
  }

  @override
  String leftStringAtIndex(int index) {
    if (index < 0 || index >= 24) return null;
    return '$index'.padLeft(2, '0');
  }

  @override
  String middleStringAtIndex(int index) {
    if (index != 0) return null;
    return ':';
  }

  @override
  String rightStringAtIndex(int index) {
    if (index < 0 || index >= 60 / 5) return null;
    return (index * 5).toString().padLeft(2, '0');
  }

  @override
  List<int> layoutProportions() => [5, 1, 5]; // Remove Middle Index

  @override
  DateTime finalTime() {
    return DateTime(
        1970, 1, 1, this.currentLeftIndex(), this.currentRightIndex() * 5);
  }
}
