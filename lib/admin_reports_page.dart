import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({Key? key}) : super(key: key);

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  Future<void> _handleReport(String reportId, String reportedUserId, String reporterUserId, bool verify, String? reporterUserName, String? reportedUserName) async {
    final reportRef = FirebaseFirestore.instance.collection('reports').doc(reportId);
    if (verify) {
      // Increment reportsReceived
      final userRef = FirebaseFirestore.instance.collection('users').doc(reportedUserId);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final userSnap = await tx.get(userRef);
        final current = (userSnap.data()?['reportsReceived'] ?? 0) as int;
        tx.update(userRef, {'reportsReceived': current + 1});
        tx.update(reportRef, {'status': 'verified'});
      });
      // Send notifications
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': reporterUserId,
        'message': 'Laporan yang anda lakukan ke atas pengguna ${reportedUserName ?? reportedUserId} telah dikenalpasti, Pengguna tersebut telah diberi amaran dan akan dikenakan tindakan lanjut jika mengulangi kesalahan pada masa akan datang',
        'timestamp': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': reportedUserId,
        'message': 'Atas kesalahan anda terhadap Pengguna ${reporterUserName ?? reporterUserId}, anda telah diberi 1 amaran. Akaun anda berisiko untuk dipadam sekiranya anda melakukan kesalahan berkali-kali',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await reportRef.update({'status': 'rejected'});
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': reporterUserId,
        'message': 'Laporan yang anda lakukan ke atas pengguna ${reportedUserName ?? reportedUserId} telah diperiksa, namun pihak kami mendapati bahawa pengguna tersebut tidak melakukan kesalahan seperti yang dimaklumkan.',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Laporan Pengguna')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text('Tiada laporan.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pelapor: ${data['reporterUserName'] ?? data['reporterUserId'] ?? 'Tidak diketahui'}'),
                      Text('Dilapor: ${data['reportedUserName'] ?? data['reportedUserId'] ?? 'Tidak diketahui'}'),
                      Text('Perkhidmatan: ${data['serviceId'] ?? '-'}'),
                      Text('Tarikh: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString() : '-'}'),
                      const SizedBox(height: 8),
                      Text('Kesalahan: ${data['description'] ?? '-'}'),
                      if (data['mediaUrl'] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.network(data['mediaUrl'], height: 120),
                        ),
                      Text('Status: ${data['status'] ?? 'pending'}', style: TextStyle(color: data['status'] == 'verified' ? Colors.green : data['status'] == 'rejected' ? Colors.red : Colors.orange)),
                      if (data['status'] == 'pending')
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _handleReport(docs[i].id, data['reportedUserId'], data['reporterUserId'], true, data['reporterUserName'], data['reportedUserName']),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: Text('Sahkan'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _handleReport(docs[i].id, data['reportedUserId'], data['reporterUserId'], false, data['reporterUserName'], data['reportedUserName']),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: Text('Tolak'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 