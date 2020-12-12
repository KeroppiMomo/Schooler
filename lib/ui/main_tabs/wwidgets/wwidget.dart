import 'dart:ui';
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
    return Padding(
      padding: _R.padding,
      child: Material(
        elevation: _R.elevation,
        color: Colors.transparent,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: _R.backgroundBlur, sigmaY: _R.backgroundBlur),
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.transparent,
              elevation: 0.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Ink(
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(_R.titleOpacity),
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
                  Ink(
                    color: _R.contentBackgroundColor,
                    child: Padding(
                      padding: contentPadding ?? _R.contentPadding,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
