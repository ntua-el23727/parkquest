import 'package:flutter/material.dart';

class SharedSpots extends StatelessWidget {
  const SharedSpots({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[100],
      body: const Center(
        child: Text(
          'Here are the shared parking spots!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
