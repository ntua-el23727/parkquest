import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  bool isTestingFlagEnabled = false; 

  @override
  void initState() {
    super.initState();
    _getTestingStatus();
  }

  Future<void> _getTestingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTestingFlagEnabled = prefs.getBool('isTestingFlagEnabled') ?? false;
    });
  }

  Future<void> _saveTestingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTestingFlagEnabled', isTestingFlagEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'This is a University Project developed by Team 80.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const Text(
              'Team Members:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('- Σταύρος Ποντίκης (03123727)', style: TextStyle(fontSize: 16)),
            const Text('- Παναγιώτης Τσακλάνος (03118937)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            const Divider(thickness: 1.5),
            const SizedBox(height: 20),
            const Text(
              'To test the app, use the toggle below to pretend that you have parked your car.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Switch(
              value: isTestingFlagEnabled, 
              onChanged: (value) {
                setState(() {
                  isTestingFlagEnabled = value;
                });
                _saveTestingStatus(); 
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(fontSize: 18),
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Main Page'),
            ),
          ],
        ),
      ),
    );
  }
}