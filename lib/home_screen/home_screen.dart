import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/henshin_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../job_proposals_page/job_proposals_page_widget.dart';
import '../request_history/request_history_widget.dart';
import '../job_application_page/job_application_widget.dart';
import '../home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4A90E2).withOpacity(0.5),
                const Color(0xFF50E3C2).withOpacity(0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Top image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Image.asset(
                      'assets/images/rh2.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Two side-by-side buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              try {
                                print('DEBUG: Navigating to Job Proposals (index 4)');
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => HomePage(initialIndex: 4)),
                                );
                              } catch (e, stack) {
                                print('NAVIGATION ERROR (Job Proposals): $e');
                                print(stack);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Navigation error: $e')),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0x66757575)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.assignment_turned_in, color: Colors.blue, size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status Permohonan Kerja',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              try {
                                print('DEBUG: Navigating to Request History (index 7)');
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => HomePage(initialIndex: 7)),
                                );
                              } catch (e, stack) {
                                print('NAVIGATION ERROR (Request History): $e');
                                print(stack);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Navigation error: $e')),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0x66757575)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people, color: Colors.blue, size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Semak Pemohon Kerja Yang Ditawarkan',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider for separation
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Divider(
                      color: Colors.black12,
                      thickness: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Kerja Terkini section with background
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                'Kerja Terkini',
                                style: GoogleFonts.ubuntu(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Latest 3 jobs
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('service_requests')
                                  .where('approved', isEqualTo: true)
                                  .orderBy('timestamp', descending: true)
                                  .limit(10)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final currentUser = FirebaseAuth.instance.currentUser;
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24.0),
                                    child: Text('Tiada kerja terkini.'),
                                  );
                                }
                                // Filter out jobs posted by the current user and check status
                                final jobs = snapshot.data!.docs.where((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final statusMap = data['status'] as Map<String, dynamic>?;
                                  final status = statusMap != null ? statusMap[currentUser?.uid] as String? : null;
                                  final isAvailable = status == null || status == 'Kerja Tersedia';
                                  return data['createdByUid'] != currentUser?.uid && isAvailable;
                                }).take(3).toList();
                                if (jobs.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24.0),
                                    child: Text('Tiada kerja terkini.'),
                                  );
                                }
                                return Column(
                                  children: jobs.map((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(color: const Color(0x66757575)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.work, color: Colors.blue, size: 32),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      data['description'] ?? 'Kerja',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    if (data['createdByEmail'] != null)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 4.0),
                                                        child: Text(
                                                          'Diminta Oleh: ${data['createdByEmail']}',
                                                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                                                        ),
                                                      ),
                                                    if (data['location'] != null && (data['location'] as String).trim().isNotEmpty)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 2.0),
                                                        child: Text(
                                                          'Lokasi: ${data['location']}',
                                                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  try {
                                                    print('DEBUG: Navigating to Job Application (index 3)');
                                                    Navigator.of(context).pushReplacement(
                                                      MaterialPageRoute(
                                                        builder: (context) => HomePage(initialIndex: 3, searchQuery: data['description'] ?? ''),
                                                      ),
                                                    );
                                                  } catch (e, stack) {
                                                    print('NAVIGATION ERROR (Kerja Terkini Lihat): $e');
                                                    print(stack);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Navigation error: $e')),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF4A90E2),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                ),
                                                child: const Text('Lihat', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            // Button to view more jobs
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    try {
                                      print('DEBUG: Navigating to Job Application (index 3)');
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => HomePage(initialIndex: 3)),
                                        );
                                    } catch (e, stack) {
                                      print('NAVIGATION ERROR (Job Application): $e');
                                      print(stack);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Navigation error: $e')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A90E2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('Lihat Kerja Selebihnya', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e, stack) {
      print('BUILD ERROR in HomeScreen: $e');
      print(stack);
      return Center(child: Text('Build error: $e'));
    }
  }
}
