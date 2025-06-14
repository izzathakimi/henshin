import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/Henshin_theme.dart';

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
        'isRead': false,
      });
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': reportedUserId,
        'message': 'Atas kesalahan anda terhadap Pengguna ${reporterUserName ?? reporterUserId}, anda telah diberi 1 amaran. Akaun anda berisiko untuk dipadam sekiranya anda melakukan kesalahan berkali-kali',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } else {
      await reportRef.update({'status': 'rejected'});
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': reporterUserId,
        'message': 'Laporan yang anda lakukan ke atas pengguna ${reportedUserName ?? reportedUserId} telah diperiksa, namun pihak kami mendapati bahawa pengguna tersebut tidak melakukan kesalahan seperti yang dimaklumkan.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: HenshinTheme.primaryGradient
              .map((color) => color.withOpacity(0.5))
              .toList(),
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text('Tiada laporan.'));
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x4D757575)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan #${i + 1}',
                        style: HenshinTheme.bodyText2.override(
                          fontFamily: 'NatoSansKhmer',
                          fontWeight: FontWeight.bold,
                          useGoogleFonts: false,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Pelapor: ${data['reporterUserName'] ?? data['reporterUserId'] ?? 'Tidak diketahui'}', style: HenshinTheme.bodyText1),
                      Text('Dilapor: ${data['reportedUserName'] ?? data['reportedUserId'] ?? 'Tidak diketahui'}', style: HenshinTheme.bodyText1),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('service_requests').doc(data['serviceId']).get(),
                        builder: (context, serviceSnap) {
                          String serviceName = data['serviceId'] ?? '-';
                          if (serviceSnap.hasData && serviceSnap.data!.exists) {
                            final serviceData = serviceSnap.data!.data() as Map<String, dynamic>?;
                            if (serviceData != null && serviceData['description'] != null) {
                              serviceName = serviceData['description'];
                            }
                          }
                          return Text('Perkhidmatan: $serviceName', style: HenshinTheme.bodyText1);
                        },
                      ),
                      Text('Tarikh: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString() : '-'}', style: HenshinTheme.bodyText1),
                      const SizedBox(height: 8),
                      Text('Kesalahan:', style: HenshinTheme.bodyText1.copyWith(fontWeight: FontWeight.bold)),
                      Text(data['description'] ?? '-', style: HenshinTheme.bodyText1),
                      if (data['mediaUrl'] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              data['mediaUrl'],
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: data['status'] == 'verified' 
                              ? Colors.green.withOpacity(0.1)
                              : data['status'] == 'rejected'
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Status: ' + (
                            data['status'] == 'verified'
                              ? 'Disahkan'
                              : data['status'] == 'rejected'
                                ? 'Ditolak'
                                : (data['status'] ?? 'pending')
                          ),
                          style: TextStyle(
                            color: data['status'] == 'verified'
                                ? Colors.green
                                : data['status'] == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (data['status'] == 'pending')
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _handleReport(docs[i].id, data['reportedUserId'], data['reporterUserId'], true, data['reporterUserName'], data['reportedUserName']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A90E2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('Sahkan', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _handleReport(docs[i].id, data['reportedUserId'], data['reporterUserId'], false, data['reporterUserName'], data['reportedUserName']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B6B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('Tolak', style: TextStyle(color: Colors.white)),
                                ),
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
        },
      ),
    );
  }
} 