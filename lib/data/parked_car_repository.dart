import 'parked_car.dart';

abstract class ParkedCarRepository {
  Future<void> saveParkedCar(ParkedCar car);
  Future<List<ParkedCar>> sharedPositionCars();
}
