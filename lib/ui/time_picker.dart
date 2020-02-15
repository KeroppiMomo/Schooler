import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class TimePicker extends CommonPickerModel {
  TimePicker({DateTime currentTime, LocaleType locale})
      : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(
        0); // Prevent initialItem != null (error from the package)
    this.setRightIndex((this.currentTime.minute / 5)
        .round()); // The TimePicker only shows minute which is divisible by 5, ie 0, 5, 10 etc.
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
