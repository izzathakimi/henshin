import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile picture'),
            Text('Personal information'),
            Text('Resume'),
            Text('Skills and qualifications list'),
            Text('Edit profile button'),
            Text('Settings button'),
            Text('Job application history'),
            Text('Ratings and reviews'),
          ],
        ),
      ),
    );
  }
}
