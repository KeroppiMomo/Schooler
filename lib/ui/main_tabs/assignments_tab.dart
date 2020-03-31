import 'package:flutter/material.dart';
import 'package:schooler/ui/assignments_list_screen.dart';
import 'package:schooler/ui/assignments_day_screen.dart';
import 'package:schooler/res/resources.dart';

final AssignmentsTabResources _R = R.assignmentTab;

class AssignmentsTab extends StatefulWidget {
  @override
  AssignmentsTabState createState() => AssignmentsTabState();
}

@visibleForTesting
class AssignmentsTabState extends State<AssignmentsTab> {
  /// Opacity of the [AssignmentListScreen]. Used for triggering the animation.
  double _opacity = 0.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AssignmentsDayScreen(
          onSwitchView: () {
            setState(() => _opacity = 1.0);
          },
        ),
        IgnorePointer(
          ignoring: _opacity == 0.0,
          child: AnimatedOpacity(
            duration: _R.switchViewDuration,
            opacity: _opacity,
            child: AssignmentsListScreen(
              onSwitchView: () {
                setState(() => _opacity = 0.0);
              },
            ),
          ),
        ),
      ],
    );
  }
}
