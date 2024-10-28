import 'package:flutter/material.dart';
import '../common/henshin_theme.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HenshinTheme.primaryColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient,
          ),
        ),
        // Placeholder ListView until we implement chat functionality
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5, // Placeholder count
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(
                    'Contact Name ${index + 1}',
                    style: HenshinTheme.subtitle1,
                  ),
                  subtitle: Text(
                    'Last message preview...',
                    style: HenshinTheme.bodyText2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    // TODO: Navigate to individual chat
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
