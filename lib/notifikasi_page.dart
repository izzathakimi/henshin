import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotifikasiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Notifikasi')),
        body: Center(child: Text('Sila log masuk untuk melihat notifikasi.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Notifikasi')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print('Snapshot: state=${snapshot.connectionState}, error=${snapshot.error}, docs=${snapshot.data?.docs.length}');

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return Center(child: Text('Tiada notifikasi.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : null;
              return ListTile(
                leading: Icon(Icons.notifications, color: Colors.blue),
                title: Text(data['message'] ?? ''),
                subtitle: timestamp != null ? Text('${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}') : null,
              );
            },
          );
        },
      ),
    );
  }
} 