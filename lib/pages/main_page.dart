import 'package:flutter/material.dart';
import 'package:parkquest/pages/find_car.dart';
import 'package:parkquest/pages/home_page.dart';
import 'package:parkquest/pages/location_saved.dart';
import 'package:parkquest/pages/shared_spots.dart';
import 'package:parkquest/pages/user_profile.dart';
import 'package:parkquest/widgets/bottom_nav_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

/* This is the main page that holds the bottom
navigation bar and switches
between different pages based on the selected index. */

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
  ).then((position) {
    Logger.root.info(
      'Current position: ${position.latitude}, ${position.longitude}',
    );
    return position;
  });
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  Position? _currentPosition;
  final Logger log = Logger('MainPage');

  @override
  void initState() {
    super.initState();
    _saveCurrentLocation();
  }

  void _saveCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle the error, e.g., show a message to the user
      print('Error getting location: $e');
    }
  }

  void _updatedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomePage(currentPosition: _currentPosition);
      case 1:
        return FindCar();
      case 2:
        return SharedSpots();
      case 3:
        return LocationSaved();
      default:
        return HomePage(currentPosition: _currentPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkQuest'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.deepPurple[50],
        width: 230,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 64,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Login'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about_us');
              },
            ),
          ],
        ),
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: _selectedIndex,
        onIndexChanged: _updatedIndex,
      ),
    );
  }
}