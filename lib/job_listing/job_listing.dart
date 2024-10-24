import 'package:flutter/material.dart';

class JobListing extends StatelessWidget {
  const JobListing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Listings'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('List of job cards'),
            Text('Infinite scroll or pagination'),
            Text('Sort options'),
            Text('Pull-to-refresh functionality'),
          ],
        ),
      ),
    );
  }
}
