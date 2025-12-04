import 'dart:async';
import 'dart:math';
import 'parked_car.dart';
import 'parked_car_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class MockParkedCarRepository implements ParkedCarRepository {
  final List<ParkedCar> _mockCars = [];
  final Random _random = Random();

  // Constructor now accepts optional current position
  MockParkedCarRepository({Position? currentPosition}) {
    _generateMockCars(currentPosition);
  }

  // ---------------------------------------------------------
  // Generate 10 mock cars with mock data + asset images
  // Cars will be nearby the current position if provided
  // ---------------------------------------------------------
  void _generateMockCars(Position? currentPosition) {
    const uuid = Uuid();

    // Default location (e.g., New York City) if no position provided
    double baseLat = currentPosition?.latitude ?? 40.7128;
    double baseLng = currentPosition?.longitude ?? -74.0060;

    for (int i = 1; i <= 10; i++) {
      // Cycle through images 1-7
      int imageNum = ((i - 1) % 7) + 1;

      // Generate random offset within ~1km radius
      // 0.009 degrees ≈ 1km at equator
      double latOffset = (_random.nextDouble() - 0.5) * 0.009;
      double lngOffset = (_random.nextDouble() - 0.5) * 0.009;

      _mockCars.add(
        ParkedCar(
          id: uuid.v4(),
          latitude: baseLat + latOffset,
          longitude: baseLng + lngOffset,
          address: "Mock Street $i, Cityville",
          savedAt: DateTime.now().subtract(Duration(hours: i)),
          note: "This is mock car #$i",
          imagePath: "assets/images/parkedcar_$imageNum.jpg",
          leftAt: DateTime.now().subtract(Duration(hours: i - 1)),
          sharedPosition: i % 2 == 0, // Every second car shares position
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // Repository methods
  // ---------------------------------------------------------
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
