import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_place/google_place.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package

class StoreFinderScreen extends StatefulWidget {
  @override
  _StoreFinderScreenState createState() => _StoreFinderScreenState();
}

class _StoreFinderScreenState extends State<StoreFinderScreen> {
  final String apiKey = 'AIzaSyBHN4zp9MdekATG760Ni_Bsop8wUwv0t8M';
  late GoogleMapController mapController;
  LatLng _initialPosition = LatLng(6.92720654127192, 79.84453252637168); // Change to nullable to handle uninitialized state
  Set<Marker> _markers = {};
  bool _isLoading = true; // Loading state

   @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Get current GPS location on initialization
  }

  // Get current location using geolocator
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false; 
      });
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _isLoading = false;// Even on error, stop loading
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getNearbyPlaces();
  }

  Future<void> _getNearbyPlaces() async {
    final response = await fetchNearbyPlaces(
        apiKey, _initialPosition.latitude, _initialPosition.longitude);

    if (response != null && response['results'] != null) {
      setState(() {
        _markers.clear();
        for (var place in response['results']) {
          _markers.add(Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(place['geometry']['location']['lat'],
                place['geometry']['location']['lng']),
            infoWindow: InfoWindow(title: place['name']),
          ));
        }
      });
    }
  }

  Future fetchNearbyPlaces(
      String apiKey, double latitude, double longitude) async {
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=1500&type=restaurant&key=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  }

Future<void> _searchPlaces(String query) async {
  final String apiUrl =
      'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=${_initialPosition.latitude},${_initialPosition.longitude}&radius=1500&key=$apiKey';
  
  final response = await http.get(Uri.parse(apiUrl));
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // Check if results are not null
    if (data['results'] != null) {
      setState(() {
        _markers.clear(); // Clear existing markers
        for (var place in data['results']) {
          _markers.add(Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(place['geometry']['location']['lat'], place['geometry']['location']['lng']),
            infoWindow: InfoWindow(title: place['name']),
          ));
        }
      });
      Navigator.pop(context);
    }
  } else {
    print('Error: ${response.statusCode} - ${response.body}');
  }
}

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while fetching the location
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Store Finder'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If location fetching failed or succeeded, build the map
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Finder'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context, delegate: PlaceSearchDelegate(_searchPlaces));
            },
          ),
        ],
      ),
      body: _initialPosition == null
          ? Center(child: Text('Failed to get location.'))
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition!,
                zoom: 14.0,
              ),
              markers: _markers,
              myLocationEnabled: true, // Show the user's location on the map
            ),
    );
  }
}

class PlaceSearchDelegate extends SearchDelegate {
  final Function(String) searchCallback;

  PlaceSearchDelegate(this.searchCallback);


  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    searchCallback(query); // Calls _searchPlaces(query)
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // You can implement suggestions UI here
  }
}
