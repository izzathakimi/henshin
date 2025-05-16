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
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor:
            HenshinTheme.primaryColor.withOpacity(0.5), // Added opacity
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
              return data['createdByEmail'] == userEmail && hasAccepted;
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
                final acceptedApplicants = statusMap?.entries
                    .where((e) => e.value == 'Diterima')
                    .map((e) => e.key)
                    .toList() ?? [];
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
                          Text(
                            'Status: Dalam Progres',
                            style: HenshinTheme.bodyText1.copyWith(color: Colors.blue),
                          ),
                          const SizedBox(height: 8),
                          Text('Pemohon Diterima:', style: HenshinTheme.bodyText1.copyWith(fontWeight: FontWeight.bold)),
                          ...acceptedApplicants.map((applicantId) => Text(applicantId, style: HenshinTheme.bodyText2)),
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
