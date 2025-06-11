import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../common/Henshin_theme.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserEmail;

  const ChatScreen({
    Key? key,
    required this.otherUserId,
    required this.otherUserEmail,
  }) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _chatId;
  String? _otherUserName;
  bool _chatReady = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _fetchOtherUserName();
  }

  Future<void> _fetchOtherUserName() async {
    final doc = await _firestore.collection('users').doc(widget.otherUserId).get();
    if (doc.exists) {
      setState(() {
        _otherUserName = doc.data()?['name'] ?? widget.otherUserEmail;
      });
    } else {
      setState(() {
        _otherUserName = widget.otherUserEmail;
      });
    }
  }

  Future<void> _initializeChat() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _chatReady = true;
      });
      return;
    }
    try {
      final List<String> participants = [currentUser.uid, widget.otherUserId]..sort();
      _chatId = participants.join('_');
      final chatDoc = await _firestore.collection('chats').doc(_chatId).get();
      if (!chatDoc.exists) {
        await _firestore.collection('chats').doc(_chatId).set({
          'participants': participants,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'messages': [],
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize chat: $e')),
      );
    } finally {
      setState(() {
        _chatReady = true;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_chatId == null) return;
    setState(() { _sending = true; });
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final now = DateTime.now();
    final message = {
      'senderId': currentUser.uid,
      'text': _messageController.text.trim(),
      'timestamp': now,
    };

    try {
      await _firestore.collection('chats').doc(_chatId).update({
        'messages': FieldValue.arrayUnion([message]),
        'lastMessage': message['text'],
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() { _sending = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(_otherUserName ?? widget.otherUserEmail),
        backgroundColor: Colors.white.withOpacity(0.2),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient.map((color) => color.withOpacity(0.5)).toList(),
          ),
        ),
        child: !_chatReady
            ? const Center(child: CircularProgressIndicator())
            : currentUser == null
                ? const Center(child: Text('You must be logged in to use chat.'))
                : Column(
                    children: [
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: _chatId == null ? null : _firestore.collection('chats').doc(_chatId).snapshots(),
                          builder: (context, snapshot) {
                            if (!_chatReady) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Center(child: Text('No messages yet'));
                            }
                            final data = snapshot.data!.data() as Map<String, dynamic>;
                            final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isMe = message['senderId'] == _auth.currentUser?.uid;
                                return Align(
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMe ? Colors.blue : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: const Color(0x66757575)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      child: Text(
                                        message['text'],
                                        style: TextStyle(
                                          color: isMe ? Colors.white : Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                enabled: _chatReady && !_sending,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: (_chatReady && !_sending) ? _sendMessage : null,
                              icon: _sending
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.send),
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
