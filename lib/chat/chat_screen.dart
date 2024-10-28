import 'package:flutter/material.dart';
import '../common/henshin_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int? selectedChatIndex;

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const TextField(
            style: TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Search messages',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
        actions: const [
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 8),
          Icon(Icons.edit, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Container(
        color: Colors.white,  // Ensure white background
        child: Column(
          children: [
            if (!isWideScreen || selectedChatIndex == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Focused', 
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip('Unread'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Drafts'),
                      const SizedBox(width: 8),
                      _buildFilterChip('InMail'),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(  // Change from ListView.builder
                itemCount: 10,
                separatorBuilder: (context, index) => Divider(  // Add divider between items
                  height: 1,
                  color: Colors.grey[300],
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    selected: selectedChatIndex == index,
                    selectedTileColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(  // Add padding
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: isWideScreen && selectedChatIndex != null
                        ? null
                        : const Text(
                            'User Name',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                    subtitle: isWideScreen && selectedChatIndex != null
                        ? null
                        : Text(
                            'Message preview...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                    trailing: isWideScreen && selectedChatIndex != null
                        ? null
                        : Text(
                            '1:01 pm',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                    onTap: () {
                      setState(() => selectedChatIndex = index);
                      _showChatDialog(context);  // Add this line to show the chat dialog
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Chat header
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage('https://placeholder.com/user'),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'User Name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                // Chat messages area
                const Expanded(
                  child: Center(
                    child: Text('Chat messages will appear here'),
                  ),
                ),
                // Message input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () {},
                      ),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label, 
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
