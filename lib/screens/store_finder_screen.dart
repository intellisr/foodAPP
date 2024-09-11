import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoreFinderScreen extends StatefulWidget {
  @override
  _StoreFinderScreenState createState() => _StoreFinderScreenState();
}

class _StoreFinderScreenState extends State<StoreFinderScreen> {
  late GoogleMapController mapController;

  static const LatLng _initialPosition = LatLng(37.7749, -122.4194); // Example: San Francisco

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Store Finder')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('store1'),
            position: LatLng(37.7749, -122.4194), // Example store location
            infoWindow: InfoWindow(title: 'Grocery Store 1'),
          ),
          Marker(
            markerId: MarkerId('store2'),
            position: LatLng(37.7849, -122.4094), // Another store location
            infoWindow: InfoWindow(title: 'Grocery Store 2'),
          ),
        },
      ),
    );
  }
}