import 'package:flutter/material.dart';
import 'package:parkquest/data/parked_car.dart';
import 'package:parkquest/data/parked_car_repository_mock.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkquest/pages/direction_maps_shared.dart';

class SharedSpots extends StatefulWidget {
  const SharedSpots({super.key});

  @override
  State<SharedSpots> createState() => _SharedSpotsState();
}

class _SharedSpotsState extends State<SharedSpots> {
  List<ParkedCar> _spots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    try {
      // 1. Βρες την τρέχουσα τοποθεσία
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // 2. Πέρνα την τοποθεσία στο Repository για να φτιάξει αμάξια κοντά σου
      final repository = MockParkedCarRepository(currentPosition: position);
      final spots = await repository.sharedPositionCars();

      if (mounted) {
        setState(() {
          _spots = spots;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback αν δεν υπάρχει GPS
      if (mounted) {
        setState(() {
           _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Spots"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _spots.length,
              itemBuilder: (context, index) {
                final spot = _spots[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      // Εικόνα Spot
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          image: DecorationImage(
                            image: AssetImage(spot.imagePath ?? 'assets/images/parkedcar_1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text("Available Spot", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${spot.distance?.toStringAsFixed(0) ?? '250'}m away"),
                        trailing: ElevatedButton.icon(
                          onPressed: () async {
  Position currentPos = await Geolocator. getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy. high),
  );

  if (! mounted) return; 
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DirectionMapsShared(
        destinationLatitude: spot.latitude,
        destinationLongitude: spot.longitude,
        originPosition: currentPos,
      ),
    ),
  );
},
                          icon: const Icon(Icons.directions, size: 18),
                          label: const Text("Go"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AEEF),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}