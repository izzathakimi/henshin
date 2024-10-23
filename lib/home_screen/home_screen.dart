import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Job categories grid or list'),
            Text('Featured/urgent job listings'),
            Text('Search bar'),
            Text('Filter options (location, job type, etc.)'),
          ],
        ),
      ),
    );
  }
}
