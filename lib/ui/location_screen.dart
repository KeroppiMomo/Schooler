import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';

LocationScreenResources _R = R.locationScreen;

class LocationScreen extends StatefulWidget {
  /// Location to view and rename.
  final LocationReminderLocation location;

  LocationScreen({Key key, this.location}) : super(key: key);

  @override
  LocationScreenState createState() => LocationScreenState();
}

@visibleForTesting
class LocationScreenState extends State<LocationScreen> {
  /// Controller for the rename TextField.
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    String name = Settings().savedLocations[widget.location];
    if (name == null) {
      // Generate a name 'My Location 1/2/3...' that does not exist in `savedLocations`
      int count = 1;
      do {
        name = _R.getNewLocationName(count);
        count++;
      } while (Settings().savedLocations.containsValue(name));
    }
    _controller = TextEditingController(text: name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_R.appBarTitle),
        leading: IconButton(
          icon: Icon(_R.cancelIcon),
          tooltip: _R.cancelText,
          onPressed: _cancelPressed,
        ),
        actions: [
          IconButton(
            icon: Icon(_R.doneIcon),
            tooltip: _R.doneText,
            onPressed: _donePressed,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: _R.instructionPadding,
            child: Text(_R.instructionText),
          ),
          Padding(
            padding: _R.textFieldPadding,
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: _R.textFieldLabelText,
                suffixIcon: IconButton(
                  icon: Icon(_R.textFieldClearIcon),
                  onPressed: () => _controller.clear(),
                  tooltip: _R.textFieldTooltip,
                ),
              ),
              onSubmitted: (_) => _donePressed(),
            ),
          ),
          if (Settings().savedLocations[widget.location] != null) Divider(),
          if (Settings().savedLocations[widget.location] != null)
            FlatButton.icon(
              icon: Icon(_R.removeIcon),
              label: Text(_R.removeText),
              onPressed: _removedPressed,
            ),
          Divider(),
          Row(
            children: [
              Expanded(
                child: FlatButton.icon(
                  icon: Icon(_R.cancelIcon),
                  label: Text(_R.cancelText),
                  onPressed: _cancelPressed,
                ),
              ),
              Container(
                height: _R.cancelDoneButtonHeight,
                child: VerticalDivider(),
              ),
              Expanded(
                child: FlatButton.icon(
                  icon: Icon(_R.doneIcon),
                  label: Text(_R.doneText),
                  onPressed: _donePressed,
                ),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: GoogleMap(
              // Disable map movement
              zoomGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.location.latitude,
                  widget.location.longitude,
                ),
                zoom: _R.mapDefaultZoom,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('location'),
                  position: LatLng(
                    widget.location.latitude,
                    widget.location.longitude,
                  ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  void _removedPressed() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_R.removeAlertTitle),
        content: Text(_R.removeAlertContent),
        actions: [
          FlatButton(
            child: Text(_R.removeAlertCancelText),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text(_R.removeAlertConfirmText),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ).then((shouldDelete) {
      // Not `if (shouldDelete)` because it might be null
      if (shouldDelete == true) {
        Settings().savedLocations.remove(widget.location);
        Settings().saveSettings();
        Navigator.of(context).pop();
      }
    });
  }

  void _cancelPressed() {
    Navigator.of(context).pop();
  }

  void _donePressed() {
    Settings().savedLocations[widget.location] = _controller.text;
    Settings().saveSettings();
    Navigator.of(context).pop();
  }
}
