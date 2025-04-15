import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../common/henshin_theme.dart';
import 'package:jiffy/jiffy.dart';

class ChatScreen extends StatefulWidget {
  final StreamChatClient client;
  final Channel channel;

  const ChatScreen({
    super.key,
    required this.client,
    required this.channel,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
              hintText: 'Mesej carian',
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
      body: StreamChannel(
        channel: widget.channel,
        child: Column(
          children: [
            if (!isWideScreen)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Fokus',
                          style: GoogleFonts.ubuntu(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip('Belum dibaca'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Draf'),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: StreamMessageListView(
                messageBuilder: (context, details, messages, defaultMessage) {
                  final message = messages[details.index];
                  final user = message.user;
                  if (user == null) return defaultMessage;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: StreamUserAvatar(
                      user: user,
                      showOnlineStatus: true,
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      message.text ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    trailing: Text(
                      Jiffy.parseFromDateTime(message.createdAt).fromNow(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      // Handle chat selection
                    },
                  );
                },
              ),
            ),
            const StreamMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.ubuntu(
          color: Colors.blue,
          fontSize: 13,
        ),
      ),
    );
  }
}
