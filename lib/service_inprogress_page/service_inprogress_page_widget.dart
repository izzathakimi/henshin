import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';
import '../service_inprogress_page2/service_inprogress_page2_widget.dart';
import '../home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceInprogressPageWidget extends StatefulWidget {
  const ServiceInprogressPageWidget({super.key});

  @override
  ServiceInprogressPageWidgetState createState() =>
      ServiceInprogressPageWidgetState();
}

class ServiceInprogressPageWidgetState
    extends State<ServiceInprogressPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;
    final userId = user?.uid;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor:
            HenshinTheme.primaryColor.withOpacity(0.5),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          child: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.black,
            size: 24,
          ),
        ),
        actions: const [],
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
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
          stream: FirebaseFirestore.instance
              .collection('service_requests')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Tiada servis dalam progres.'));
            }
            final inProgressDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final statusMap = data['status'] as Map<String, dynamic>?;
              final hasAccepted = statusMap?.values.contains('Diterima') ?? false;
              final isOwner = data['createdByEmail'] == userEmail;
              final isAcceptedApplicant = statusMap?.entries.any((e) => e.key == userId && e.value == 'Diterima') ?? false;
              final isSelesai = data['status'] != null && (statusMap?.values.contains('Selesai') ?? false);
              return (isOwner || isAcceptedApplicant) && hasAccepted && !isSelesai;
            }).toList();
            if (inProgressDocs.isEmpty) {
              return Center(child: Text('Tiada servis dalam progres.'));
            }
            return ListView.builder(
              itemCount: inProgressDocs.length,
              itemBuilder: (context, index) {
                final doc = inProgressDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                final statusMap = data['status'] as Map<String, dynamic>?;
                final ownerEmail = data['createdByEmail'];
                final ownerId = data['createdById'];
                String? acceptedApplicantId;
                if (statusMap != null) {
                  final found = statusMap.entries.firstWhere(
                    (e) => e.value == 'Diterima',
                    orElse: () => const MapEntry<String, dynamic>('', null),
                  );
                  acceptedApplicantId = found.key.isNotEmpty ? found.key : null;
                }
                final ownerConfirmed = data['ownerConfirmed'] == true;
                final applicantConfirmed = data['applicantConfirmed'] == true;
                final isOwner = ownerEmail == userEmail;
                final isAcceptedApplicant = acceptedApplicantId == userId;
                // Fetch owner and applicant names
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchUsers([ownerId, acceptedApplicantId]),
                  builder: (context, userSnap) {
                    String ownerName = ownerEmail;
                    String applicantName = acceptedApplicantId ?? '-';
                    if (userSnap.hasData) {
                      for (var u in userSnap.data!) {
                        if (u['id'] == ownerId && u['name'] != null) ownerName = u['name'];
                        if (u['id'] == acceptedApplicantId && u['name'] != null) applicantName = u['name'];
                      }
                    }
                    // Confirmation logic
                    String waitingMsg = '';
                    if (ownerConfirmed && !applicantConfirmed) waitingMsg = 'Menunggu Konfirmasi dari Penerima';
                    if (!ownerConfirmed && applicantConfirmed) waitingMsg = 'Menunggu Konfirmasi dari Pemohon';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
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
                                data['description'] ?? 'Servis',
                                style: HenshinTheme.bodyText2.override(
                                  fontFamily: 'NatoSansKhmer',
                                  fontWeight: FontWeight.bold,
                                  useGoogleFonts: false,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Pemohon: $ownerName', style: HenshinTheme.bodyText1),
                              Text('Penerima: $applicantName', style: HenshinTheme.bodyText1),
                              const SizedBox(height: 8),
                              Text('Status: Dalam Progres', style: HenshinTheme.bodyText1.copyWith(color: Colors.blue)),
                              if (waitingMsg.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(waitingMsg, style: TextStyle(color: Colors.orange)),
                                ),
                              const SizedBox(height: 8),
                              if ((isOwner && !ownerConfirmed) || (isAcceptedApplicant && !applicantConfirmed))
                                ElevatedButton(
                                  onPressed: () async {
                                    if (isOwner) {
                                      await FirebaseFirestore.instance.collection('service_requests').doc(doc.id).update({'ownerConfirmed': true});
                                    } else if (isAcceptedApplicant) {
                                      await FirebaseFirestore.instance.collection('service_requests').doc(doc.id).update({'applicantConfirmed': true});
                                    }
                                    // Show review dialog immediately after confirmation
                                    await _showReviewDialog(context, isOwner, doc.id, ownerId, acceptedApplicantId);
                                    // If both confirmed, set status to Selesai
                                    final updatedDoc = await FirebaseFirestore.instance.collection('service_requests').doc(doc.id).get();
                                    final updatedData = updatedDoc.data() as Map<String, dynamic>;
                                    if (updatedData['ownerConfirmed'] == true && updatedData['applicantConfirmed'] == true) {
                                      await FirebaseFirestore.instance.collection('service_requests').doc(doc.id).update({'status.$acceptedApplicantId': 'Selesai'});
                                    }
                                  },
                                  child: Text('Selesai'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUsers(List<String?> userIds) async {
    final ids = userIds.where((id) => id != null).toList();
    if (ids.isEmpty) return [];
    final usersSnap = await FirebaseFirestore.instance
        .collection('freelancers')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return usersSnap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _showReviewDialog(BuildContext context, bool isOwner, String docId, String? ownerId, String? applicantId) async {
    double rating = 5;
    TextEditingController reviewController = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Beri Penilaian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sila beri rating dan ulasan anda'),
              const SizedBox(height: 8),
              // If flutter_rating_bar is not available, use a simple slider
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Slider(
                        value: rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: rating.toString(),
                        onChanged: (r) => setState(() => rating = r),
                      ),
                      Text('Rating: ${rating.toStringAsFixed(1)}'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(hintText: 'Tulis ulasan...'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reviewData = {
                  'rating': rating,
                  'review': reviewController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                };
                if (isOwner) {
                  await FirebaseFirestore.instance.collection('service_requests').doc(docId).update({'ownerReview': reviewData});
                } else {
                  await FirebaseFirestore.instance.collection('service_requests').doc(docId).update({'applicantReview': reviewData});
                }
                Navigator.pop(context);
              },
              child: Text('Hantar'),
            ),
          ],
        );
      },
    );
  }
}
