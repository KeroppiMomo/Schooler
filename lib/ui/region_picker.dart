import 'dart:math';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schooler/lib/geofencing.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/location_screen.dart';

RegionPickerResources _R = R.regionPicker;

class RegionPicker extends StatefulWidget {
  final LocationReminderTrigger trigger;

  RegionPicker({Key key, @required this.trigger}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RegionPickerState();

  static Future<LocationReminderTrigger> showPicker(BuildContext context,
      {@required LocationReminderTrigger trigger}) {
    return showModalBottomSheet<LocationReminderTrigger>(
      context: context,
      isScrollControlled: true,
      enableDrag: false, // Google Maps require drag
      builder: (context) => SingleChildScrollView(
        child: RegionPicker(trigger: trigger),
      ),
    );
  }
}

@visibleForTesting
class RegionPickerState extends State<RegionPicker> {
  /// Temporary trigger object of the current picker state.
  LocationReminderTrigger _trigger = _R.defaultTrigger;

  /// Controller for the radius TextField.
  TextEditingController _radiusController;

  /// Controller for the Google Map.
  GoogleMapController _mapController;

  /// Zoom level of the Google Map.
  ///
  /// This is to prevent the async call to `_mapController.getZoomLevel()`.
  /// This is used to calculate the screen size of the region circle.
  double _mapZoomLevel;

  /// Screen coordinate of the pin in the Google Map.
  ///
  /// This is used to draw the region circle and the pin.
  ScreenCoordinate _mapPinScreenPoint;

  @override
  void initState() {
    super.initState();

    if (widget.trigger.region != null) {
      // Clone widget.trigger to prevent passing by reference
      _trigger = LocationReminderTrigger.fromJSON(widget.trigger.toJSON());
    }

    _radiusController =
        TextEditingController(text: _trigger.region.radius.toString());
    _radiusController.addListener(() {
      _radiusOnChanged(int.tryParse(_radiusController.text) ?? 0,
          changeTextField: false);
    });
    _mapZoomLevel = _R.defaultZoomLevel;

    if (widget.trigger.region == null) {
      _locationButtonPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(children: [
            CupertinoButton(
              pressedOpacity: _R.headerButtonPressedOpacity,
              padding: _R.headerButtonPadding,
              child: Text(
                _R.cancelButtonText,
                style: _R.cancelButtonTextStyle,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(child: Container()),
            CupertinoButton(
              pressedOpacity: _R.headerButtonPressedOpacity,
              padding: _R.headerButtonPadding,
              child: Text(
                _R.doneButtonText,
                style: _R.doneButtonTextStyle,
              ),
              onPressed: () => Navigator.pop(context, _trigger),
            ),
          ]),
          _buildGeofenceEventOption(),
          _buildRadiusOption(),
          _buildLocationOption(),
          Divider(),
          _buildMap(),
        ],
      ),
    );
  }

  Widget _buildOption(
      {@required String title, @required List<Widget> content}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: _R.optionTitleWidth,
            child: Text(
              title,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: _R.optionTitleContentSpacing),
          ...content,
        ],
      ),
    );
  }

  Widget _buildGeofenceEventOption() {
    return _buildOption(
      title: _R.geofenceEventTitle,
      content: [
        Spacer(),
        ChoiceChip(
          label: Text(_R.geofenceEnterText),
          selected: _trigger.geofenceEvent == GeofenceEvent.enter,
          onSelected: (value) {
            if (value) {
              setState(() => _trigger.geofenceEvent = GeofenceEvent.enter);
            }
          },
        ),
        Spacer(),
        ChoiceChip(
          label: Text(_R.geofenceExitText),
          selected: _trigger.geofenceEvent == GeofenceEvent.exit,
          onSelected: (value) {
            if (value) {
              setState(() => _trigger.geofenceEvent = GeofenceEvent.exit);
            }
          },
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildRadiusOption() {
    return _buildOption(
      title: _R.radiusTitle,
      content: [
        Expanded(
          child: Slider(
            value: max(
              min(
                _trigger.region.radius.toDouble(),
                _R.radiusSliderMax.toDouble(),
              ),
              _R.radiusSliderMin.toDouble(),
            ), // bound to min to max
            min: _R.radiusSliderMin.toDouble(),
            max: _R.radiusSliderMax.toDouble(),
            divisions: (_R.radiusSliderMax - _R.radiusSliderMin) ~/
                _R.radiusSliderStep,
            onChanged: (double value) => _radiusOnChanged(value.toInt()),
          ),
        ),
        SizedBox(
          width: _R.radiusTextFieldWidth,
          child: TextField(
            controller: _radiusController,
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: false),
            textAlign: TextAlign.right,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
        Text(_R.radiusUnitText),
      ],
    );
  }

  Widget _buildLocationOption() {
    int listIndex = Settings()
        .savedLocations
        .keys
        .toList()
        .indexOf(_trigger.region.location);
    if (listIndex == -1) listIndex = Settings().savedLocations.length;

    return _buildOption(
      title: _R.locationTitle,
      content: [
        Expanded(
          child: DropdownButton<int>(
            value: listIndex,
            isExpanded: true,
            items: List.generate(
              Settings().savedLocations.length + 1,
              (index) => DropdownMenuItem(
                value: index,
                child: Text(
                  index == Settings().savedLocations.length
                      ? _R.locationNewLocationText
                      : Settings().savedLocations.values.toList()[index],
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
              ),
            ),
            onChanged: (index) => _locationOnSelected(
                index == Settings().savedLocations.length
                    ? _trigger.region.location
                    : Settings().savedLocations.keys.toList()[index],
                saved: index != Settings().savedLocations.length),
          ),
        ),
        IconButton(
          icon: Icon(_R.locationRenameIcon),
          tooltip: _R.locationRenameTooltip,
          onPressed: _renamePressed,
        ),
      ],
    );
  }

  Widget _buildMap() {
    // Set a hard limit to the circle size. Flutter freezes when a widget is too big.
    double circleRadius = min(
        MediaQuery.of(context).size.width * 5,
        _trigger.region.radius /
            zoomLevel2MeterPerPx(
                _mapZoomLevel, _trigger.region.location.latitude));
    return SizedBox(
      height: _R.mapHeight,
      child: Stack(
        children: [
          GoogleMap(
            // Don't know why the My Location button doesn't work
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(_trigger.region.location.latitude,
                  _trigger.region.location.longitude),
              zoom: _mapZoomLevel,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _mapOnMove,
          ),

          if (_trigger.geofenceEvent == GeofenceEvent.exit)
            // Outside blue area
            IgnorePointer(
              child: ClipRRect(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      _R.mapRegionFilledColor, BlendMode.srcOut),
                  child: LayoutBuilder(
                    builder: (context, constraints) => Container(
                      color: Colors.transparent,
                      child: OverflowBox(
                        minWidth: 0,
                        minHeight: 0,
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: Transform.translate(
                          offset: _mapPinScreenPoint == null
                              ? Offset(0, 0)
                              : Offset(
                                  _mapPinScreenPoint.x -
                                      constraints.maxWidth / 2,
                                  _mapPinScreenPoint.y -
                                      constraints.maxHeight / 2,
                                ),
                          child: Container(
                            width: circleRadius * 2,
                            height: circleRadius * 2,
                            decoration: BoxDecoration(
                              color: _R.mapRegionBorderColor,
                              borderRadius: BorderRadius.circular(circleRadius),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (_trigger.geofenceEvent == GeofenceEvent.exit)
            // Blue border
            IgnorePointer(
              child: ClipRRect(
                child: LayoutBuilder(
                  builder: (context, constraints) => OverflowBox(
                    minWidth: 0,
                    minHeight: 0,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: Transform.translate(
                      offset: _mapPinScreenPoint == null
                          ? Offset(0, 0)
                          : Offset(
                              _mapPinScreenPoint.x - constraints.maxWidth / 2,
                              _mapPinScreenPoint.y - constraints.maxHeight / 2,
                            ),
                      child: Container(
                        width: circleRadius * 2,
                        height: circleRadius * 2,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _R.mapRegionBorderColor,
                            width: _R.mapRegionBorderWidth,
                          ),
                          borderRadius: BorderRadius.circular(circleRadius),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (_trigger.geofenceEvent == GeofenceEvent.enter)
            // Blue circle and border
            IgnorePointer(
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) => OverflowBox(
                    minWidth: 0,
                    minHeight: 0,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: Transform.translate(
                      offset: _mapPinScreenPoint == null
                          ? Offset(0, 0)
                          : Offset(
                              _mapPinScreenPoint.x.toDouble() -
                                  constraints.maxWidth / 2,
                              _mapPinScreenPoint.y.toDouble() -
                                  constraints.maxHeight / 2,
                            ),
                      child: Container(
                        height: circleRadius * 2,
                        width: circleRadius * 2,
                        decoration: BoxDecoration(
                          color: _R.mapRegionFilledColor,
                          border: Border.all(
                            width: _R.mapRegionBorderWidth,
                            color: _R.mapRegionBorderColor,
                          ),
                          borderRadius: BorderRadius.circular(circleRadius),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Pin
          IgnorePointer(
            child: ClipRRect(
              child: LayoutBuilder(
                builder: (context, constraints) => Transform.translate(
                  offset: _mapPinScreenPoint == null
                      ? Offset(0, -_R.mapPinSize / 2)
                      : Offset(
                          _mapPinScreenPoint.x - constraints.maxWidth / 2,
                          _mapPinScreenPoint.y -
                              constraints.maxHeight / 2 -
                              _R.mapPinSize / 2,
                        ),
                  child: Center(
                    child: Icon(
                      Icons.place,
                      size: _R.mapPinSize,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // For whatever reason, Google Map's My Location button doesn't work
          Positioned(
            right: _R.mapMyLocationMarginRight,
            bottom: _R.mapMyLocationMarginBottom,
            child: FloatingActionButton(
              child: Icon(_R.mapMyLocationIcon),
              onPressed: _locationButtonPressed,
            ),
          ),
        ],
      ),
    );
  }

  void _radiusOnChanged(int value, {bool changeTextField = true}) {
    setState(() {
      if (changeTextField) {
        _radiusController.text = value.toString();
      }
      _trigger.region.radius = value;
    });
  }

  void _locationOnSelected(LocationReminderLocation newLocation, {bool saved}) {
    setState(() {
      if (saved) {
        _trigger.region.location =
            LocationReminderLocation.fromJSON(newLocation.toJSON());
      } else {
        _trigger.region.location = LocationReminderLocation(
            latitude: newLocation.latitude + 0.00000001,
            longitude: newLocation.longitude + 0.00000001);
      }
      _mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(newLocation.latitude, newLocation.longitude)));
    });
  }

  void _renamePressed() {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) =>
                LocationScreen(location: _trigger.region.location)))
        .then((_) {
      setState(() {});
    });
  }

  void _mapOnMove(CameraPosition camPos) {
    setState(() {
      var location = _trigger.region.location;
      if (Settings().savedLocations[location] == null) {
        location.latitude = camPos.target.latitude;
        location.longitude = camPos.target.longitude;
        _mapPinScreenPoint = null;
      } else {
        _mapController
            .getScreenCoordinate(LatLng(location.latitude, location.longitude))
            .then((coordinate) {
          // BEWARE! The documentation for `GoogleMapController.getScreenCoordinate` is WRONG.
          //
          // From the documentation: "Screen location is in screen pixels (not display pixels)..."
          // This only applies to Android API, not iOS API. iOS API returns a CGPoint, which is
          // independent from the device's pixel ratio.
          //
          // Dividing by `devicePixelRatio` is platform-specific.
          //
          // Android's `Projection.toScreenLocation(LatLng location)`: https://developers.google.com/android/reference/com/google/android/gms/maps/Projection?hl=zh-tw#public-point-toscreenlocation-latlng-location
          // iOS's `GMSProjection.pointForCoordinate(CLLocationCoordinate2D coordinate)`: https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_projection#member-function-documentation

          if (Platform.isAndroid) {
            final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
            _mapPinScreenPoint = ScreenCoordinate(
              x: (coordinate.x / devicePixelRatio).round(),
              y: (coordinate.y / devicePixelRatio).round(),
            );
          } else {
            _mapPinScreenPoint = coordinate;
          }
        });
      }
      _mapZoomLevel = camPos.zoom;
    });
  }

  void _locationButtonPressed() async {
    try {
      final position = await Geolocator().getCurrentPosition();
      _mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)));
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_R.myLocationFailedTitle),
          content: Text(_R.myLocationFailedContent),
          actions: [
            FlatButton(
              child: Text(_R.myLocationFailedOKText),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }
}

// https://gis.stackexchange.com/a/127949
double zoomLevel2MeterPerPx(double zoom, double latitude) {
  return 156543.03392 * cos(latitude * pi / 180) / pow(2, zoom);
}
