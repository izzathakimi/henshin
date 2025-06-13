import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobProposalsPageWidget extends StatefulWidget {
  const JobProposalsPageWidget({super.key});

  @override
  JobProposalsPageWidgetState createState() => JobProposalsPageWidgetState();
}

class JobProposalsPageWidgetState extends State<JobProposalsPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(
      //   backgroundColor: HenshinTheme.primaryColor.withOpacity(0.5),
      //   automaticallyImplyLeading: false,
      //   leading: InkWell(
      //     onTap: () {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const HomePage()),
      //       );
      //     },
      //     child: const Icon(
      //       Icons.keyboard_arrow_left_outlined,
      //       color: Colors.black,
      //       size: 24,
      //     ),
      //   ),
      //   actions: const [],
      //   centerTitle: true,
      //   elevation: 0,
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient.map((color) => color.withOpacity(0.5)).toList(),
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('service_requests').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Tiada permohonan kerja.'));
            }
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return Center(child: Text('Sila log masuk.'));
            }
            final userId = user.uid;
            // Filter jobs: only show if status[userId] == 'Dimohon' and approved == true
            final appliedDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final statusMap = data['status'] as Map<String, dynamic>?;
              final status = statusMap != null ? statusMap[userId] as String? : null;
              final approved = data['approved'] == true;
              return approved && status == 'Dimohon';
            }).toList();
            if (appliedDocs.isEmpty) {
              return Center(child: Text('Tiada permohonan kerja.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 32, bottom: 32),
              itemCount: appliedDocs.length,
              itemBuilder: (context, index) {
                final doc = appliedDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x66757575)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: HenshinTheme.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.work, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        data['description'] ?? 'Kerja',
                                        style: HenshinTheme.bodyText1.override(
                                          fontFamily: 'NatoSansKhmer',
                                          fontWeight: FontWeight.bold,
                                          useGoogleFonts: false,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      data['timestamp'] != null
                                          ? (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16)
                                          : '',
                                      style: HenshinTheme.bodyText1.override(
                                        fontFamily: 'NatoSansKhmer',
                                        color: const Color(0x99303030),
                                        useGoogleFonts: false,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Diminta Oleh: ${data['createdByEmail'] ?? '-'}',
                                  style: HenshinTheme.bodyText1.override(
                                    fontFamily: 'NatoSansKhmer',
                                    color: Colors.black54,
                                    useGoogleFonts: false,
                                    fontSize: 13,
                                  ),
                                ),
                                if (data['location'] != null && (data['location'] as String).trim().isNotEmpty)
                                  Text(
                                    'Lokasi: ${data['location']}',
                                    style: HenshinTheme.bodyText1.override(
                                      fontFamily: 'NatoSansKhmer',
                                      color: Colors.black54,
                                      useGoogleFonts: false,
                                      fontSize: 13,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Harga: RM${data['price'] ?? '-'} (${data['paymentRate'] ?? ''})',
                                  style: HenshinTheme.bodyText1,
                                ),
                                if (data['requirements'] != null && data['requirements'] is List)
                                  ...List.generate(
                                    (data['requirements'] as List).length,
                                    (i) => Text('- ${data['requirements'][i]}', style: HenshinTheme.bodyText1),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      'Status: Dimohon',
                                      style: HenshinTheme.bodyText1.override(
                                        fontFamily: 'NatoSansKhmer',
                                        color: Colors.green,
                                        useGoogleFonts: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
