import 'dart:async';
import 'dart:math';
import 'parked_car.dart';
import 'parked_car_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class MockParkedCarRepository implements ParkedCarRepository {
  final List<ParkedCar> _mockCars = [];
  final Random _random = Random();

  MockParkedCarRepository({Position? currentPosition}) {
    _generateMockCars(currentPosition);
  }

  void _generateMockCars(Position? currentPosition) {
    const uuid = Uuid();

    // Default location (e.g., New York) if no position provided
    double baseLat = currentPosition?.latitude ?? 40.7128;
    double baseLng = currentPosition?.longitude ?? -74.0060;

    for (int i = 1; i <= 10; i++) {
      int imageNum = ((i - 1) % 7) + 1;

      // Random offset within ~1km radius
      double latOffset = (_random.nextDouble() - 0.5) * 0.009;
      double lngOffset = (_random.nextDouble() - 0.5) * 0.009;
      
      double carLat = baseLat + latOffset;
      double carLng = baseLng + lngOffset;

      // Υπολογισμός απόστασης από το κέντρο (χρήστη)
      double dist = Geolocator.distanceBetween(baseLat, baseLng, carLat, carLng);

      _mockCars.add(
        ParkedCar(
          id: uuid.v4(),
          latitude: carLat,
          longitude: carLng,
          address: "Mock Street $i, Cityville",
          savedAt: DateTime.now().subtract(Duration(hours: i)),
          note: "This is mock car #$i",
          imagePath: "assets/images/parkedcar_$imageNum.jpg",
          leftAt: DateTime.now().subtract(Duration(hours: i - 1)),
          sharedPosition: i % 2 == 0, 
          distance: dist, // <--- Αποθήκευση της απόστασης
        ),
      );
    }
  }

  @override
  Future<void> saveParkedCar(ParkedCar car) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockCars.add(car);
  }

  @override
  Future<List<ParkedCar>> sharedPositionCars() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockCars.where((car) => car.sharedPosition).toList();
  }
}