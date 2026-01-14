import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onIndexChanged,
      destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Find Car'),
        NavigationDestination(icon: Icon(Icons.group), label: 'Shared Spots'),
      ],
    );
  }
}