import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('List of conversations'),
            Text('Search contacts'),
            Text('Individual chat windows'),
            Text('Option to share job listings or profiles'),
          ],
        ),
      ),
    );
  }
}
