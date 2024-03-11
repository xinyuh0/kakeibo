import 'package:flutter_map/flutter_map.dart';
import 'package:kkb/assets/colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/cupertino.dart';
import 'package:kkb/assets/icons.dart';

class MapArea extends StatefulWidget {
  final String location;
  final double height;
  final bool editMode;
  final Color color;
  final Function(String s) notifyChange;

  const MapArea(
      {super.key,
      required this.location,
      required this.height,
      required this.editMode,
      required this.color,
      required this.notifyChange});

  @override
  State<MapArea> createState() => MapAreaState();
}

class MapAreaState extends State<MapArea> {
  double zoom = 18.0;

  late MapController _mapController;

  bool get showMarker => location.isSet;
  bool showMap = false;
  late bool editMode;

  Location currentLocation = Location();
  Location location = Location();

  String getLocation() => location.str;

  setEditMode(bool mode) {
    setState(() {
      editMode = mode;
    });
  }

  @override
  void initState() {
    super.initState();
    editMode = widget.editMode;
    _mapController = MapController();
    location.setLocationFromStr(widget.location);

    if (!location.isSet) {
      _setCurrentLocation();
      location.setLocationFromStr(currentLocation.str);
    } else {
      showMap = true;
    }
  }

  Future<void> _setCurrentLocation() async {
    String s = await _getCurrentLocation();
    setState(() {
      currentLocation.setLocationFromStr(s);
      showMap = true;
    });
  }

  void _setLocation(String s) {
    setState(() {
      location.setLocationFromStr(s);
    });
    widget.notifyChange(location.str);
  }

  void _moveMap() {
    _mapController.move(location.latLng, zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxHeight: widget.height),
        padding: const EdgeInsets.only(right: 50, left: 50, top: 0, bottom: 10),
        child: !showMap
            ? const Center(
                child: CupertinoActivityIndicator(),
              )
            : FlutterMap(
                options: MapOptions(
                  initialCenter: location.latLng,
                  initialZoom: zoom,
                  keepAlive: true,
                  onTap: editMode
                      ? (tapPosition, point) => {
                            setState(() {
                              _setLocation(
                                  '${point.latitude},${point.longitude}');
                            }),
                          }
                      : null,
                ),
                mapController: _mapController,
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: showMarker
                        ? [
                            Marker(
                                point: location.latLng,
                                width: 35,
                                height: 35,
                                child: Icon(
                                  iconLocation,
                                  color: editMode ? systemBlue : widget.color,
                                  size: 30,
                                )),
                          ]
                        : [],
                  ),
                  editMode
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: 35,
                                      height: 35,
                                      margin: const EdgeInsets.only(top:0, left:0, right:5, bottom: 4),
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: whiteTransp,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CupertinoButton(
                                        padding: const EdgeInsets.all(0),
                                          child: const Icon(iconMyLocation,
                                              color: systemBlue),
                                          onPressed: () async {
                                            await _setCurrentLocation();
                                            if (currentLocation.isSet) {
                                              _setLocation(currentLocation.str);
                                              _moveMap();
                                            }
                                          }),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 35,
                                      height: 35,
                                      margin: const EdgeInsets.only(top:4, left:0, right:5, bottom: 5),
                                      decoration: const BoxDecoration(
                                        color: whiteTransp,
                                        shape: BoxShape.circle,
                                        
                                      ),
                                      child: CupertinoButton(
                                        padding: const EdgeInsets.all(0),
                                        child: const Icon(iconLocationOff,
                                            color: systemBlue),
                                        onPressed: () => setState(() {
                                          _setLocation('');
                                        }),
                                      ),
                                    ),
                                  ])
                            ])
                      : Container(),
                ],
              ));
  }

  Future<String> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are permanently denied.');
        }

        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      return '';
    }
  }
}

LatLng defaultLatLng = const LatLng(35.7128, 139.7592);

class Location {
  String _str = '';
  LatLng _latLng = defaultLatLng;

  String get str => _str;
  LatLng get latLng => _latLng;
  bool get isSet => _str != '';

  void setLocationFromStr(String s) {
    try {
      double lat = double.parse(s.split(',')[0]);
      double lng = double.parse(s.split(',')[1]);
      _latLng = LatLng(lat, lng);
      _str = '$lat,$lng';
    } catch (e) {
      _latLng = defaultLatLng;
      _str = '';
    }
  }
}
