import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:parkquest/widgets/group_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final Logger _logger = Logger('LocationSaved');

Future<Position> _determinePosition() async {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled return an error message
    return Future.error('Location services are disabled.');
  }

  // Check location permissions
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  // If permissions are granted, return the current location
  return await Geolocator.getCurrentPosition(
    locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
  );
}

Future<void> savedCarParkLocation(Position position) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble('latitude', position.latitude);
    await preferences.setDouble('longitude', position.longitude);
    await preferences.setBool('isLocationSaved', true);
    await preferences.setString(
      'saved_timestamp',
      DateTime.now().toIso8601String(),
    );
    _logger.info('Location saved: ${position.latitude}, ${position.longitude}');
  } catch (e) {
    _logger.severe('Error saving location: $e');
    throw e; // Re-throw so the UI can handle the error
  }
}

class LocationSaved extends StatefulWidget {
  const LocationSaved({super.key});

  @override
  State<LocationSaved> createState() => _LocationSavedState();
}

class _LocationSavedState extends State<LocationSaved> {
  bool _locationSaved = false;
  String? _errorMessage;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _saveCurrentLocation();
  }

  Future<void> _saveCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      await savedCarParkLocation(position);
      setState(() {
        _currentPosition = position;
        _locationSaved = true;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Saved'), centerTitle: true),
      body: Center(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Text('Error: $_errorMessage');
    } else if (_locationSaved && _currentPosition != null) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          SizedBox(
            height: 400,
            width: 500,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 16,
              ),
              mapType: MapType.normal,
              markers: {
                Marker(
                  markerId: MarkerId('parked_car'),
                  position: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Your Car',
                    snippet:
                        'Parked here at ${DateTime.now().toString().substring(11, 16)}',
                  ),
                ),
              },
            ),
          ),
          SizedBox(height: 70),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(
                'Location Saved Successfully!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 50),
          LocationSavedActionButtons(
            selectedIndex: 0,
            onIndexChanged: (index) {
              // Handle button actions here
            },
          ),
        ],
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Saving your location...'),
          ],
        ),
      ); // Show loading
    }
  }
}
