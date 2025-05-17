import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatScreenDirect extends StatefulWidget {
  final StreamChatClient client;
  final String targetUserId;
  final String? targetUserName;

  const ChatScreenDirect({
    Key? key,
    required this.client,
    required this.targetUserId,
    this.targetUserName,
  }) : super(key: key);

  @override
  State<ChatScreenDirect> createState() => _ChatScreenDirectState();
}

class _ChatScreenDirectState extends State<ChatScreenDirect> {
  Channel? _channel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  Future<void> _initChannel() async {
    final currentUser = widget.client.state.currentUser;
    if (currentUser == null) return;
    final members = [currentUser.id, widget.targetUserId];
    final channel = widget.client.channel(
      'messaging',
      extraData: {
        'members': members,
      },
    );
    await channel.watch();
    setState(() {
      _channel = channel;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _channel == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return StreamChannel(
      channel: _channel!,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            widget.targetUserName ?? 'Chat',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: const [
            Expanded(child: StreamMessageListView()),
            StreamMessageInput(),
          ],
        ),
      ),
    );
  }
} 