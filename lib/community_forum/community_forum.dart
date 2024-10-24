import 'package:flutter/material.dart';

class CommunityForum extends StatelessWidget {
  const CommunityForum({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('List of forum topics/threads'),
            Text('Create new post button'),
            Text('Search and filter options'),
            Text('User reputation indicators'),
          ],
        ),
      ),
    );
  }
}
