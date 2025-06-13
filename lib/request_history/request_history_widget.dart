import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/Henshin_theme.dart';
// import '../request_summary/request_summary_widget.dart'; // Remove this line since RequestSummaryWidget is no longer used
import 'package:firebase_auth/firebase_auth.dart';
import '../profile_screen/profile.dart';
import '../home_page.dart';
// Add this import for navigation to user profile
// import '../user_profile/user_profile_page.dart'; // Uncomment and adjust path if you have a profile page

class RequestHistoryWidget extends StatelessWidget {
  const RequestHistoryWidget({super.key});

  Future<List<Map<String, dynamic>>> _fetchApplicants(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();
    return usersSnap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient.map((color) => color.withOpacity(0.5)).toList(),          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('service_requests')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: HenshinTheme.bodyText1.copyWith(color: Colors.white),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Tiada permintaan sebelumnya',
                  style: HenshinTheme.bodyText1.copyWith(color: Colors.white),
                ),
              );
            }

            final user = FirebaseAuth.instance.currentUser;
            final userEmail = user?.email;
            final userDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['createdByEmail'] == userEmail;
            }).toList();

            if (userDocs.isEmpty) {
              return Center(
                child: Text(
                  'Tiada permintaan sebelumnya',
                  style: HenshinTheme.bodyText1.copyWith(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userDocs.length,
              itemBuilder: (context, index) {
                final doc = userDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                // Get applicant userIds
                final statusMap = data['status'] as Map<String, dynamic>?;
                final applicantIds = statusMap == null
                    ? <String>[]
                    : statusMap.entries
                        .where((e) => e.value == 'Dimohon')
                        .map((e) => e.key)
                        .toList();

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['description'] ?? 'No description',
                                style: HenshinTheme.subtitle1,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (data['approved'] == true)
                                  ? 'Status: Disahkan'
                                  : 'Status: Dalam Proses Pengesahan',
                                style: TextStyle(
                                  color: data['approved'] == true ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'RM ${(data['price'] ?? 0.0).toStringAsFixed(2)}',
                                style: HenshinTheme.bodyText1.copyWith(
                                  color: HenshinTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (timestamp != null)
                                Text(
                                  '${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                  style: HenshinTheme.bodyText2.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              // APPLICANTS SECTION
                              if (applicantIds.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Pemohon:', style: HenshinTheme.bodyText1.copyWith(fontWeight: FontWeight.bold)),
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future: _fetchApplicants(applicantIds),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: LinearProgressIndicator(),
                                      );
                                    }
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Text('Tiada pemohon.', style: HenshinTheme.bodyText2);
                                    }
                                    final applicants = snapshot.data!;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: applicants.map((app) {
                                        final applicantId = app['id'];
                                        final applicantEmail = app['email'] ?? applicantId;
                                        final status = (statusMap != null && statusMap[applicantId] != null) ? statusMap[applicantId] : null;
                                        if (status != 'Dimohon') return SizedBox.shrink();
                                        return Row(
                                          children: [
                                            Expanded(flex: 2, child: Text(applicantEmail)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 1,
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (_) => Profile(userId: applicantId)),
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(color: HenshinTheme.primaryColor, width: 2),
                                                  foregroundColor: HenshinTheme.primaryColor,
                                                  backgroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                child: const Text('Lihat'),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 1,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance
                                                      .collection('service_requests')
                                                      .doc(doc.id)
                                                      .update({'status.$applicantId': 'Diterima'});
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: HenshinTheme.primaryColor,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                child: const Text('Terima'),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                          trailing: null,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // edit logic (reuse your existing edit logic here)
                                    final descController = TextEditingController(text: data['description'] ?? '');
                                    final priceController = TextEditingController(text: (data['price'] ?? '').toString());
                                    final paymentRateController = TextEditingController(text: data['paymentRate'] ?? '');
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Edit Permintaan'),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: descController,
                                                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                                                ),
                                                TextField(
                                                  controller: priceController,
                                                  decoration: const InputDecoration(labelText: 'Harga'),
                                                  keyboardType: TextInputType.number,
                                                ),
                                                TextField(
                                                  controller: paymentRateController,
                                                  decoration: const InputDecoration(labelText: 'Kadar Bayaran'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    style: OutlinedButton.styleFrom(
                                                      side: BorderSide(color: Colors.blue, width: 2),
                                                      foregroundColor: Colors.blue,
                                                      backgroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    child: const Text('Batal'),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.blue,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    child: const Text('Simpan'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (result == true) {
                                      await FirebaseFirestore.instance
                                          .collection('service_requests')
                                          .doc(doc.id)
                                          .update({
                                        'description': descController.text,
                                        'price': double.tryParse(priceController.text) ?? 0.0,
                                        'paymentRate': paymentRateController.text,
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Ubah'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // delete logic (reuse your existing delete logic here)
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Padam Permintaan'),
                                        content: const Text('Anda pasti mahu memadam permintaan ini?'),
                                        actions: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  style: OutlinedButton.styleFrom(
                                                    side: BorderSide(color: Colors.blue, width: 2),
                                                    foregroundColor: Colors.blue,
                                                    backgroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  child: const Text('Batal'),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.redAccent,
                                                    foregroundColor: Colors.white,
                                                    shape: const StadiumBorder(),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  child: const Text('Padam'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await FirebaseFirestore.instance
                                          .collection('service_requests')
                                          .doc(doc.id)
                                          .delete();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Padam'),
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
      ),
    );
  }
}
