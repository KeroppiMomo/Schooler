import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';

WWidgetResources _R = R.wwidget;

// The sections in the Today screen are called Widgets.
// To avoid confusion, non-Flutter widgets are called WWidgets in code.
class WWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  /// Set to null to hide the settings button.
  final void Function() onSettingsPressed;

  /// Set to null to hide the refresh button.
  final void Function() onRefreshPressed;
  final EdgeInsets contentPadding;

  WWidget({
    Key key,
    @required this.title,
    @required this.icon,
    @required this.child,
    this.onSettingsPressed,
    this.onRefreshPressed,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorOnPrimaryColor =
        Theme.of(context).primaryColorBrightness == Brightness.light
            ? Colors.black
            : Colors.white;
    return Card(
      child: Column(
        children: [
          Ink(
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                SizedBox(width: _R.titleItemsSpacing),
                Icon(
                  icon,
                  color: colorOnPrimaryColor,
                  size: _R.titleIconSize,
                ),
                SizedBox(width: _R.titleItemsSpacing),
                Text(
                  title,
                  style: _R
                      .titleTextStyle(context)
                      .copyWith(color: colorOnPrimaryColor),
                ),
                Expanded(child: Container()),
                ...onRefreshPressed == null
                    ? []
                    : [
                        InkWell(
                          child: Padding(
                            padding: _R.titleActionIconPadding,
                            child: Icon(
                              _R.refreshIcon,
                              color: colorOnPrimaryColor,
                              size: _R.titleIconSize,
                            ),
                          ),
                          onTap: onRefreshPressed,
                        )
                      ],
                ...onSettingsPressed == null
                    ? []
                    : [
                        InkWell(
                          child: Padding(
                            padding: _R.titleActionIconPadding,
                            child: Icon(
                              _R.settingsIcon,
                              color: colorOnPrimaryColor,
                              size: _R.titleIconSize,
                            ),
                          ),
                          onTap: onSettingsPressed,
                        )
                      ],
              ],
            ),
          ),
          Padding(
            padding: contentPadding ?? _R.contentPadding,
            child: child,
          ),
        ],
      ),
    );
  }
}
