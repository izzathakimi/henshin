import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../common/Henshin_theme.dart';

class JobApplicationPageWidget extends StatefulWidget {
  final String? searchQuery;
  const JobApplicationPageWidget({super.key, this.searchQuery});

  @override
  JobApplicationPageWidgetState createState() =>
      JobApplicationPageWidgetState();
}

class JobApplicationPageWidgetState extends State<JobApplicationPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationSearchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    print('DEBUG: JobApplicationPageWidget searchQuery: \\${widget.searchQuery}');
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchController.text = widget.searchQuery!;
      _searchQuery = widget.searchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(
      //   backgroundColor: HenshinTheme.primaryColor.withOpacity(0.5),
      //   automaticallyImplyLeading: false,
      //   // leading: InkWell(
      //   //   onTap: () {
      //   //     Navigator.pushReplacement(
      //   //       context,
      //   //       MaterialPageRoute(builder: (context) => const HomePage()),
      //   //     );
      //   //   },
      //   //   child: const Icon(
      //   //     Icons.keyboard_arrow_left_outlined,
      //   //     color: Colors.black,
      //   //     size: 24,
      //   //   ),
      //   // ),
      //   title: Container(
      //     height: 40,
      //     margin: const EdgeInsets.only(left: 0),
      //     child: TextField(
      //       controller: _searchController,
      //       onChanged: (value) {
      //         setState(() {
      //           _searchQuery = value;
      //         });
      //       },
      //       style: HenshinTheme.bodyText1,
      //       decoration: InputDecoration(
      //         hintText: 'Cari kerja...',
      //         hintStyle: HenshinTheme.bodyText1.copyWith(color: Colors.grey[600]),
      //         prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
      //         filled: true,
      //         fillColor: Colors.white,
      //         contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      //         border: OutlineInputBorder(
      //           borderRadius: BorderRadius.circular(20),
      //           borderSide: BorderSide.none,
      //         ),
      //         isDense: true,
      //       ),
      //     ),
      //   ),
      //   centerTitle: false,
      //   elevation: 0,
      // ),
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
            // Search bar for job title/description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari kerja...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            // Search bar for location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: TextField(
                controller: _locationSearchController,
                decoration: InputDecoration(
                  hintText: 'Cari lokasi...',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('service_requests')
                    .where('approved', isEqualTo: true)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  final searchQuery = _searchController.text.trim().toLowerCase();
                  final locationQuery = _locationSearchController.text.trim().toLowerCase();
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = (data['description'] ?? '').toString().toLowerCase();
                    final location = (data['location'] ?? '').toString().toLowerCase();
                    final matchesTitle = searchQuery.isEmpty || title.contains(searchQuery);
                    final matchesLocation = locationQuery.isEmpty || location.contains(locationQuery);
                    return matchesTitle && matchesLocation;
                  }).toList();
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final statusMap = data['status'] as Map<String, dynamic>?;
                      final status = statusMap != null ? statusMap[FirebaseAuth.instance.currentUser?.uid] as String? : null;
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
                                            'Status: ${status ?? 'Kerja Tersedia'}',
                                            style: HenshinTheme.bodyText1.override(
                                              fontFamily: 'NatoSansKhmer',
                                              color: status == 'Dimohon' ? Colors.green : Colors.blue,
                                              useGoogleFonts: false,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (status == null || status == 'Kerja Tersedia')
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance.collection('service_requests').doc(doc.id).update({
                                                    'status.$FirebaseAuth.instance.currentUser?.uid': 'Dimohon',
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF4A90E2),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                ),
                                                child: const Text('Mohon', style: TextStyle(color: Colors.white)),
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
          ],
        ),
      ),
    );
  }
}
