import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkquest/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'dart:io';

import 'dart:math';

final Logger _logger = Logger('DirectionMap');
final Random random = Random();

Future<Position> getSavedCarLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double? latitude = prefs.getDouble('latitude');
  double? longitude = prefs.getDouble('longitude');

  if (latitude != null && longitude != null) {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  } else {
    throw Exception('No saved car location found.');
  }
}

class DirectionMap extends StatefulWidget {
  const DirectionMap({super.key});

  @override
  State<DirectionMap> createState() => _DirectionMapState();
}

class _DirectionMapState extends State<DirectionMap> {
  Position? _carSavedPosition; //this is the destination
  Position? _userCurrentPosition; //this is the starting point
  bool isTestingFlagEnabled = false;
  GoogleMapController? mapController;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints? polylinePoints;
  String? errorMessage;
  bool isLoading = false;
  RoutesApiResponse? currentResponse;
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  bool _dialogShown = false; // Track if dialog has been shown

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load and set the testing flag first
    isTestingFlagEnabled = await _isTestingFlagEnabled();
    // Then load positions based on the flag
    await _loadCarPosition();
    await _loadUserCurrentPosition();

    // After loading positions, set up polyline points and markers
    if (_carSavedPosition != null && _userCurrentPosition != null) {
      polylinePoints = PolylinePoints.enhanced(apiKey);
      _addMarker(
        LatLng(_userCurrentPosition!.latitude, _userCurrentPosition!.longitude),
        'origin',
        BitmapDescriptor.defaultMarker,
      );
      _addMarker(
        LatLng(_carSavedPosition!.latitude, _carSavedPosition!.longitude),
        'destination',
        BitmapDescriptor.defaultMarkerWithHue(90),
      );
      await _getEnhancedRoute();
    }
  }

  Future<void> _loadCarPosition() async {
    try {
      Position position = await getSavedCarLocation();
      if (mounted) {
        setState(() {
          _carSavedPosition = position;
        });
      }
    } catch (e) {
      _logger.warning('Failed to load car position: $e');
    }
  }

  Future<void> _loadUserCurrentPosition() async {
    if (isTestingFlagEnabled) {
      // In testing mode, use a fake location near the car
      if (_carSavedPosition != null) {
        // Generate small random offsets (roughly within 500 meters)
        double randomLatitude =
            _carSavedPosition!.latitude + (random.nextDouble() - 0.5) * 0.009;
        double randomLongitude =
            _carSavedPosition!.longitude + (random.nextDouble() - 0.5) * 0.009;
        if (mounted) {
          setState(() {
            _userCurrentPosition = Position(
              latitude: randomLatitude,
              longitude: randomLongitude,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
            );
          });
        }
      }
      return;
    }

    // Not in testing mode - use actual user location
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _userCurrentPosition = position;
        });
      }
    } catch (e) {
      _logger.warning('Failed to load user current position: $e');
    }
  }

  Future<bool> _isTestingFlagEnabled() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool('isTestingFlagEnabled') ?? false;
  }

  Future<bool> _carfound() async {
    if (_carSavedPosition == null || _userCurrentPosition == null) return false;
    double distanceInMeters = Geolocator.distanceBetween(
      _carSavedPosition!.latitude,
      _carSavedPosition!.longitude,
      _userCurrentPosition!.latitude,
      _userCurrentPosition!.longitude,
    );
    return distanceInMeters < 10; // Consider car found 10 meters
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    final markerId = MarkerId(id);
    final marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
      infoWindow: InfoWindow(
        title: id == 'origin' ? 'Your Location' : 'Car Location',
      ),
    );
    markers[markerId] = marker;
    if (mounted) {
      setState(() {});
    }
  }

  void _addPolyLine(
    List<LatLng> coordinates, {
    Color color = Colors.blue,
    String id = 'poly',
  }) {
    final polylineId = PolylineId(id);
    final polyline = Polyline(
      polylineId: polylineId,
      color: color,
      points: coordinates,
      width: 5,
    );
    polylines[polylineId] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getEnhancedRoute() async {
    if (_userCurrentPosition == null || _carSavedPosition == null) return;

    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
        polylineCoordinates.clear();
        polylines.clear();
        currentResponse = null;
      });
    }

    try {
      final response = await polylinePoints!.getRouteBetweenCoordinatesV2(
        request: RequestConverter.createEnhancedRequest(
          origin: PointLatLng(
            _userCurrentPosition!.latitude,
            _userCurrentPosition!.longitude,
          ),
          destination: PointLatLng(
            _carSavedPosition!.latitude,
            _carSavedPosition!.longitude,
          ),
        ),
      );

      if (mounted) {
        setState(() {
          currentResponse = response;
        });
      }

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        if (route.polylinePoints != null) {
          // Convert to LatLng list
          final coordinates = route.polylinePoints!
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
          _addPolyLine(coordinates, color: Colors.blue);
        } else {
          // Fallback: try converting enhanced response to legacy result
          final legacy = polylinePoints!.convertToLegacyResult(response);
          final pts = legacy.points;
          final coords = pts
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
          if (coords.isNotEmpty) _addPolyLine(coords, color: Colors.blue);
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = response.errorMessage ?? 'No route found';
          });
        }
      }
    } catch (e) {
      _logger.warning('Error getting route: $e');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Get back to your Car!')),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton:
          _carSavedPosition != null && _userCurrentPosition != null
          ? ExpandableFab(
              openButtonBuilder: RotateFloatingActionButtonBuilder(
                child: const Icon(Icons.menu),
                fabSize: ExpandableFabSize.regular,
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
              ),
              closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                child: const Icon(Icons.close),
                fabSize: ExpandableFabSize.small,
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: const CircleBorder(),
              ),
              children: [
                FloatingActionButton.small(
                  heroTag: 'note',
                  child: const Icon(Icons.note),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? savedNote = prefs.getString('parkingNote');

                    if (mounted) {
                      if (savedNote != null && savedNote.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Parking Note'),
                            content: SingleChildScrollView(
                              child: Text(savedNote),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No parking note saved'),
                          ),
                        );
                      }
                    }
                  },
                ),
                FloatingActionButton.small(
                  heroTag: 'photo',
                  child: const Icon(Icons.photo),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? photoPath = prefs.getString('parkingPhotoPath');

                    if (mounted) {
                      if (photoPath != null && await File(photoPath).exists()) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.file(File(photoPath)),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No parking photo saved'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          FutureBuilder<bool>(
            future: _carfound(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final carFound = snapshot.data ?? false;

              // Show alert when car is found
              if (carFound) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Only show dialog once
                  if (!_dialogShown) {
                    _dialogShown = true;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: Theme.of(context).primaryColor,
                        title: const Text('Car found!'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(
                                'Share the car location you are about to leave and earn 5 Points!',
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainPage(),
                                ),
                              );
                            },
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: const Color(0xFF90E0EF),
                            ),
                            child: const Text('Share'),
                            onPressed: () {
                              // _carSavedPosition is still available here for sharing
                              Navigator.of(dialogContext).pop();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (dialogContext2) => AlertDialog(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  title: const Text('Points Earned!'),
                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                          'Great Job! You have earned 5 Points!',
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: const Color(
                                          0xFF90E0EF,
                                        ),
                                      ),
                                      child: const Text('Get back home'),
                                      onPressed: () async {
                                        // Clear saved location data
                                        SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.remove('latitude');
                                        await prefs.remove('longitude');
                                        await prefs.setBool(
                                          'isLocationSaved',
                                          false,
                                        );
                                        await prefs.remove('saved_timestamp');
                                        await prefs.remove('parkingNote');
                                        await prefs.remove('parkingPhotoPath');

                                        if (mounted) {
                                          Navigator.of(dialogContext2).pop();
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MainPage(),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                });
                // Return empty container when car is found (alert will show)
                return const SizedBox.shrink();
              }

              // Show map when car is NOT found
              if (_carSavedPosition != null && _userCurrentPosition != null) {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _userCurrentPosition!.latitude,
                      _userCurrentPosition!.longitude,
                    ),
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  tiltGesturesEnabled: true,
                  compassEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: _onMapCreated,
                  markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: $errorMessage',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
