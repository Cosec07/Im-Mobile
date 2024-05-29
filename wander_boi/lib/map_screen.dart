import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'database_helper.dart';

class MapScreen extends StatefulWidget {
  final int? sessionId;

  MapScreen({this.sessionId});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location location = new Location();
  LatLng currentLatLng = LatLng(37.7749, -122.4194); // Default location (San Francisco)
  MapController mapController = MapController();
  List<LatLng> path = [];
  int? sessionId;
  bool isSessionActive = false;
  double totalDistance = 0.0;
  int startTime = 0;
  int endTime = 0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _startNewSession() async {
    sessionId = await DatabaseHelper().createSession();
    setState(() {
      path = [];
      isSessionActive = true;
      startTime = DateTime.now().millisecondsSinceEpoch;
    });
  }

  Future<void> _endSession() async {
    if (sessionId != null) {
      await DatabaseHelper().endSession(sessionId!);
      setState(() {
        isSessionActive = false;
        endTime = DateTime.now().millisecondsSinceEpoch;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) async {
      if (isSessionActive && sessionId != null) {
        LatLng newLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);

        setState(() {
          currentLatLng = newLatLng;
          if (path.isNotEmpty) {
            totalDistance += Distance().as(LengthUnit.Kilometer, path.last, newLatLng);
          }
          path.add(currentLatLng);
        });

        await DatabaseHelper().insertLatLng(sessionId!, newLatLng);

        mapController.move(currentLatLng, 15.0);
      }
    });
  }

  String getTimeElapsed() {
    if (startTime == 0 || endTime == 0) return "0 seconds";
    int seconds = (endTime - startTime) ~/ 1000;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;
    return "${hours}h ${minutes % 60}m ${seconds % 60}s";
  }

  @override
  void dispose() {
    if (isSessionActive) {
      _endSession();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Map'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (isSessionActive) {
              _endSession();
            }
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentLatLng,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: path,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: currentLatLng,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Distance: ${totalDistance.toStringAsFixed(2)} km"),
                Text("Time Elapsed: ${getTimeElapsed()}"),
                ElevatedButton(
                  onPressed: isSessionActive ? _endSession : _startNewSession,
                  child: Text(isSessionActive ? 'End Session' : 'Start Session'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
