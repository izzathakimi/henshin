import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({Key? key}) : super(key: key);

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  Future<void> _handleReport(String reportId, String reportedUserId, String reporterUserId, bool verify) async {
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
        'message': 'Laporan yang anda lakukan ke atas pengguna @$reportedUserId telah dikenalpasti, Pengguna tersebut telah diberi amaran dan akan dikenakan tindakan lanjut jika mengulangi kesalahan pada masa akan datang',
        'timestamp': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': reportedUserId,
        'message': 'Atas kesalahan anda terhadap Pengguna @$reporterUserId, anda telah diberi 1 amaran. Akaun anda berisiko untuk dipadam sekiranya anda melakukan kesalahan berkali-kali',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await reportRef.update({'status': 'rejected'});
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': reporterUserId,
        'message': 'Laporan yang anda lakukan ke atas pengguna @$reportedUserId telah diperiksa, namun pihak kami mendapati bahawa pengguna tersebut tidak melakukan kesalahan seperti yang dimaklumkan.',
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
                      FutureBuilder<List<DocumentSnapshot>>(
                        future: Future.wait([
                          FirebaseFirestore.instance.collection('users').doc(data['reporterUserId']).get(),
                          FirebaseFirestore.instance.collection('users').doc(data['reportedUserId']).get(),
                        ]),
                        builder: (context, snap) {
                          String reporterName = data['reporterUserId'] ?? 'Tidak diketahui';
                          String reportedName = data['reportedUserId'] ?? 'Tidak diketahui';
                          if (snap.hasData) {
                            final reporterData = snap.data![0].data() as Map<String, dynamic>?;
                            final reportedData = snap.data![1].data() as Map<String, dynamic>?;
                            if (reporterData != null && reporterData['name'] != null && (reporterData['name'] as String).isNotEmpty) reporterName = reporterData['name'];
                            else reporterName = 'Tidak diketahui';
                            if (reportedData != null && reportedData['name'] != null && (reportedData['name'] as String).isNotEmpty) reportedName = reportedData['name'];
                            else reportedName = 'Tidak diketahui';
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pelapor: $reporterName'),
                              Text('Dilapor: $reportedName'),
                            ],
                          );
                        },
                      ),
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
                              onPressed: () => _handleReport(docs[i].id, data['reportedUserId'], data['reporterUserId'], true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: Text('Sahkan'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _handleReport(docs[i].id, data['reportedUserId'], data['reporterUserId'], false),
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