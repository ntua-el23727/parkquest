import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:parkquest/pages/location_saved.dart';
import 'package:parkquest/pages/direction_maps shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:parkquest/data/parked_car.dart';
import 'package:parkquest/data/parked_car_repository_mock.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  final Position? currentPosition;

  const HomePage({super.key, this.currentPosition});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLocationSaved = false;
  List<ParkedCar> _sharedCars = [];
  MockParkedCarRepository? _repository;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
    _initializeRepository();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize repository if currentPosition changes from null to a value
    if (oldWidget.currentPosition == null && widget.currentPosition != null) {
      _initializeRepository();
    }
  }

  Future<void> _initializeRepository() async {
    // Initialize repository with current position
    _repository = MockParkedCarRepository(
      currentPosition: widget.currentPosition,
    );
    await _loadSharedCars();
  }

  Future<void> _loadSharedCars() async {
    if (_repository == null) return;
    final cars = await _repository!.sharedPositionCars();
    if (mounted) {
      setState(() {
        _sharedCars = cars;
      });
    }
  }

  Future<void> _checkLocationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isLocationSaved = prefs.getBool('isLocationSaved') ?? false;
        Logger.root.info('Location saved status: $_isLocationSaved');
      });
    }
  }

  Future<void> _deleteSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('latitude');
    await prefs.remove('longitude');
    await prefs.setBool('isLocationSaved', false); // Set to false, not remove
    await prefs.remove('saved_timestamp');
    await prefs.remove('parkingNote'); // Also clear parking note
    await prefs.remove('parkingPhotoPath'); // Also clear parking photo
    if (mounted) {
      setState(() {
        _isLocationSaved = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40),
          Text(
            'Welcome to ParkQuest!',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Press the + button to add and save your car location.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          Divider(thickness: 2, indent: 20, endIndent: 20, color: Colors.black),
          SizedBox(height: 5),
          Text(
            'Recent Free Parking Spots Near You:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          SizedBox(height: 200, child: _buildCarousel()),
          SizedBox(height: 30),
          if (_isLocationSaved)
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Car location saved! Press "Find Car" to get directions.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _deleteSavedLocation();
                        },
                        child: Text('Delete Saved Location'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 18),
                foregroundColor: Colors.black,
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationSaved(),
                  ),
                );
                // Refresh the location status when returning
                _checkLocationStatus();
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add Parking Location'),
                ],
              ),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    if (_sharedCars.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: RepaintBoundary(
        child: CarouselView(
          scrollDirection: Axis.horizontal,
          itemExtent: 350.0,
          shrinkExtent: 20.0,
          elevation: 5.0,
          onTap: (int index) {
            final car = _sharedCars[index];
            Logger.root.info(
              'Tapped on car: ${car.id}, lat: ${car.latitude}, lng: ${car.longitude}',
            );

            if (widget.currentPosition == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Getting your location...')),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DirectionMapsShared(
                  destinationLatitude: car.latitude,
                  destinationLongitude: car.longitude,
                  originPosition: widget.currentPosition!,
                ),
              ),
            );
          },
          children: _sharedCars.map((car) {
            if (car.imagePath == null) {
              return const Center(child: Text('No image available'));
            }

            // Simple image widget without tap handling
            return car.imagePath!.startsWith('assets/')
                ? Image(image: AssetImage(car.imagePath!), fit: BoxFit.cover)
                : Image.file(File(car.imagePath!), fit: BoxFit.cover);
          }).toList(),
        ),
      ),
    );
  }
}
