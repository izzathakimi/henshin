import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../common/Henshin_theme.dart';

class JobApplicationPageWidget extends StatefulWidget {
  const JobApplicationPageWidget({super.key});

  @override
  JobApplicationPageWidgetState createState() =>
      JobApplicationPageWidgetState();
}

class JobApplicationPageWidgetState extends State<JobApplicationPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: HenshinTheme.primaryColor.withOpacity(0.5),
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
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(left: 0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: HenshinTheme.bodyText1,
            decoration: InputDecoration(
              hintText: 'Cari kerja...',
              hintStyle: HenshinTheme.bodyText1.copyWith(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient.map((color) => color.withOpacity(0.5)).toList(),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('service_requests').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Tiada kerja tersedia.'));
                  }
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    return Center(child: Text('Sila log masuk.'));
                  }
                  final userId = user.uid;
                  final userEmail = user.email;
                  // Only show jobs NOT posted by the current user
                  final availableDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final statusMap = data['status'] as Map<String, dynamic>?;
                    final status = statusMap != null ? statusMap[userId] as String? : null;
                    final approved = data['approved'] == true;
                    final createdByEmail = data['createdByEmail'];
                    final description = (data['description'] ?? '').toString().toLowerCase();
                    final requirements = (data['requirements'] is List)
                      ? (data['requirements'] as List).map((e) => e.toString().toLowerCase()).join(' ')
                      : '';
                    final query = _searchQuery.toLowerCase();
                    final matchesQuery = query.isEmpty ||
                      description.contains(query) ||
                      requirements.contains(query);
                    return approved && (status == null || status == 'Kerja Tersedia') && createdByEmail != userEmail && matchesQuery;
                  }).toList();
                  if (availableDocs.isEmpty) {
                    return Center(child: Text('Tiada kerja tersedia.'));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: availableDocs.length,
                    itemBuilder: (context, index) {
                      final doc = availableDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final statusMap = data['status'] as Map<String, dynamic>?;
                      final status = statusMap != null ? statusMap[userId] as String? : null;
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
                                            'Status: ${status ?? 'Kerja Tersedia'}',
                                            style: HenshinTheme.bodyText1.override(
                                              fontFamily: 'NatoSansKhmer',
                                              color: status == 'Dimohon' ? Colors.green : Colors.blue,
                                              useGoogleFonts: false,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (status == null || status == 'Kerja Tersedia')
                                            ElevatedButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance.collection('service_requests').doc(doc.id).update({
                                                  'status.$userId': 'Dimohon',
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: HenshinTheme.primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                              ),
                                              child: const Text('Mohon'),
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
          ],
        ),
      ),
    );
  }
}
