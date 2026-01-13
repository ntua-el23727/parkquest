import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('DirectionMapsShared');

class DirectionMapsShared extends StatefulWidget {
  final double destinationLatitude;
  final double destinationLongitude;
  final Position originPosition;

  const DirectionMapsShared({
    super.key,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.originPosition,
  });

  @override
  State<DirectionMapsShared> createState() => _DirectionMapsSharedState();
}

class _DirectionMapsSharedState extends State<DirectionMapsShared> {
  Position? _destination; // The shared parking spot
  Position? _origin; // User's current location
  GoogleMapController? mapController;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints? polylinePoints;
  String? errorMessage;
  bool isLoading = false;
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Set origin from passed parameter
    _origin = widget.originPosition;

    // Set destination from passed parameters
    _destination = Position(
      latitude: widget.destinationLatitude,
      longitude: widget.destinationLongitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );

    _logger.info('Origin: ${_origin?.latitude}, ${_origin?.longitude}');
    _logger.info(
      'Destination: ${_destination?.latitude}, ${_destination?.longitude}',
    );

    // Set up polyline points and markers
    if (_destination != null && _origin != null) {
      polylinePoints = PolylinePoints.enhanced(apiKey);
      _addMarker(
        LatLng(_origin!.latitude, _origin!.longitude),
        'origin',
        BitmapDescriptor.defaultMarker,
      );
      _addMarker(
        LatLng(_destination!.latitude, _destination!.longitude),
        'destination',
        BitmapDescriptor.defaultMarkerWithHue(90),
      );
      await _getEnhancedRoute();
    } else {
      _logger.warning('Origin or destination is null!');
    }
  }

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    final markerId = MarkerId(id);
    final marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
      infoWindow: InfoWindow(
        title: id == 'origin' ? 'Your Location' : 'Parking Spot',
      ),
    );
    markers[markerId] = marker;
    setState(() {});
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
    setState(() {});
  }

  Future<void> _getEnhancedRoute() async {
    if (_origin == null || _destination == null) return;

    _logger.info(
      'Getting route from (${_origin!.latitude}, ${_origin!.longitude}) to (${_destination!.latitude}, ${_destination!.longitude})',
    );

    setState(() {
      isLoading = true;
      errorMessage = null;
      polylines.clear();
    });

    try {
      final response = await polylinePoints!.getRouteBetweenCoordinatesV2(
        request: RequestConverter.createEnhancedRequest(
          origin: PointLatLng(_origin!.latitude, _origin!.longitude),
          destination: PointLatLng(
            _destination!.latitude,
            _destination!.longitude,
          ),
        ),
      );

      _logger.info('API Response - Routes count: ${response.routes.length}');
      if (response.errorMessage != null) {
        _logger.warning('API Error: ${response.errorMessage}');
      }

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        if (route.polylinePoints != null) {
          final coordinates = route.polylinePoints!
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
          _logger.info('Polyline points: ${coordinates.length}');
          _addPolyLine(coordinates, color: Colors.blue);
        } else {
          final legacy = polylinePoints!.convertToLegacyResult(response);
          final coords = legacy.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
          _logger.info('Legacy points: ${coords.length}');
          if (coords.isNotEmpty) _addPolyLine(coords, color: Colors.blue);
        }
      } else {
        setState(() {
          errorMessage = response.errorMessage ?? 'No route found';
        });
      }
    } catch (e) {
      _logger.warning('Error getting route: $e');
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Directions to Parking Spot')),
      body: Stack(
        children: [
          (_destination != null && _origin != null)
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_origin!.latitude, _origin!.longitude),
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  tiltGesturesEnabled: true,
                  compassEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  onMapCreated: (controller) => mapController = controller,
                  markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                )
              : const Center(child: CircularProgressIndicator()),
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