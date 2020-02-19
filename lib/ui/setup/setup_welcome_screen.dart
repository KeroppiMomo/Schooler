import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:schooler/ui/setup/calendar_type_screen.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/lib/settings.dart';

SetupWelcomeScreenResources _R = R.setupWelcomeScreen;

class SetupWelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Settings().calendarType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getStarted(context);
      });
    }

    final textColor =
        Theme.of(context).primaryColorBrightness == Brightness.light
            ? Colors.black
            : Colors.white;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SizedBox.expand(
        child: Padding(
          padding: _R.padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconShadowWidget(
                Icon(
                  _R.icon,
                  size: MediaQuery.of(context).size.width -
                      _R.padding.left -
                      _R.padding.right,
                  color: textColor,
                ),
                shadowColor: _R.iconShadowColor,
              ),
              Text(
                _R.titleText,
                textAlign: TextAlign.center,
                style: _R.getTitleTextStyle(context).copyWith(color: textColor),
              ),
              SizedBox(height: _R.itemSpacing),
              Text(
                _R.messageText,
                textAlign: TextAlign.center,
                style:
                    _R.getMessageTextStyle(context).copyWith(color: textColor),
              ),
              SizedBox(height: _R.itemSpacing),
              RaisedButton(
                child: Text(_R.buttonText),
                color: textColor,
                splashColor: _R.getButtonSplashColor(context),
                onPressed: () => _getStarted(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getStarted(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CalendarTypeScreen()));
  }
}
