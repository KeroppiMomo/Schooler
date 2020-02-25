import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';

SubjectBlockResources _R = R.subjectBlock;

class SubjectBlock extends StatelessWidget {
  final String name;
  final Color color;

  SubjectBlock({Key key, @required this.name, @required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light
            ? Colors.black
            : Colors.white;
    return Padding(
      padding: _R.margin,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
                10000.0), // Large border radius -> Max border radius
          ),
          child: Padding(
            padding: _R.textPadding,
            child: Text(
              name,
              style: _R.getTextStyle(context).copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
