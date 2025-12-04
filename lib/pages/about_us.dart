import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  bool isTestingFlagEnabled = false; // Use non-nullable with default value

  @override
  void initState() {
    super.initState();
    _testingStatus();
  }

  Future<void> _testingStatus() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isTestingFlagEnabled =
          preferences.getBool('isTestingFlagEnabled') ?? false;
    });
  }

  Future<void> saveBool() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isTestingFlagEnabled', isTestingFlagEnabled);
    //print(isTestingFlagEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us')),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'This is a University Project developed by Team 80.',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 50),
                  Text(
                    'Team Members:\n- Σταύρος Ποντίκης (03123727)\n- Παναγιώτης Τσακλάνος (03118937)\n',
                    style: TextStyle(fontSize: 18),
                  ),
                  Divider(
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.black,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'To test the app please use the toggle below to pretend that you have parked your car.',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Switch(
                    value: isTestingFlagEnabled, // Shows current state
                    onChanged: (value) {
                      setState(() {
                        isTestingFlagEnabled = value; // Update the variable
                      });
                      saveBool(); // Save it permanently
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Back to Main Page'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
