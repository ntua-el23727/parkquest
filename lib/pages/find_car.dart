import 'package:flutter/material.dart';
import 'package:parkquest/pages/direction_maps.dart';
import 'package:parkquest/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FindCar extends StatefulWidget {
  const FindCar({super.key});

  @override
  State<FindCar> createState() => _FindCarState();
}

class _FindCarState extends State<FindCar> {
  bool isCarLocationSaved = false;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCarLocationSaved = prefs.getBool('isLocationSaved') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCarLocationSaved) {
      return AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Ready to return back to your car?'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Simply press Get Directions to get safely back to your parked car',
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFF90E0EF),
            ),
            child: const Text('Get Directions'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DirectionMap()),
              );
            },
          ),
        ],
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No saved car location found.',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please go back and save your car location first.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18),
                  foregroundColor: Colors.black,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
