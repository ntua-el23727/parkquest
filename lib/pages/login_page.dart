import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Page')),
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Text(
          'Welcome to ParkQuest! Please log in.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
