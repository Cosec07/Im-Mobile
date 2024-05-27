import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location location = new Location();
  LatLng currentLatLng = LatLng(19.076090,72.877426);
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled){
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.requestPermission();
      if(_permissionGranted != PermissionStatus.granted){
        return;
      }
    }
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
          currentLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          mapController.move(currentLatLng, 15.0);
        });
      });
    }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Explore Map'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ),
    body: FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLatLng,
        initialZoom: 13.0, 
      ),
    
      children: [TileLayer(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: const ['a', 'b', 'c'],
      ),
      MarkerLayer(markers: [
        Marker(
          point: LatLng(30,40), 
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
  );
}  
}