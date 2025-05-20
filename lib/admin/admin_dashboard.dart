import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../splash/splash_widget.dart';
import 'create_admin.dart';
import '../common/Henshin_theme.dart';
import 'akaun_pengguna_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  late int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _titles = [
    'Permohonan Perkhidmatan',
    'Cipta Pentadbir',
    'Akaun Pengguna',
  ];

  final List<Map<String, dynamic>> _drawerItems = [
    {'icon': Icons.work, 'title': 'Permohonan Perkhidmatan', 'index': 0},
    {'icon': Icons.admin_panel_settings, 'title': 'Cipta Pentadbir', 'index': 1},
    {'icon': Icons.people, 'title': 'Akaun Pengguna', 'index': 2},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SplashWidget()),
      );
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        errorMessage = 'Firebase Error: ${e.message}';
      } else {
        errorMessage = 'Logout failed: $e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Widget _buildServiceRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('service_requests')
          .where('approved', isEqualTo: false)
          // .orderBy('timestamp', descending: true) // TEMPORARILY REMOVED FOR DEBUGGING
          .snapshots(),
      builder: (context, snapshot) {
        print('AdminDashboard DEBUG: snapshot.hasData=${snapshot.hasData}, docs=${snapshot.data?.docs.length}');
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            print('AdminDashboard DEBUG: doc=${doc.data()}');
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tiada permohonan perkhidmatan baharu.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.work, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['description'] ?? 'Tiada deskripsi',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Diminta oleh: ${data['createdByEmail'] ?? 'Unknown'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Harga: RM${data['price'] ?? '0'} (${data['paymentRate'] ?? 'Per Jam'})',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (data['requirements'] != null && data['requirements'] is List)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Keperluan:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...List.generate(
                            (data['requirements'] as List).length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Text('• ${data['requirements'][i]}'),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await _firestore.collection('service_requests').doc(doc.id).delete();
                          },
                          child: const Text('Tolak'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await _firestore.collection('service_requests').doc(doc.id).update({
                              'approved': true,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Terima'),
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
    );
  }

  Widget _buildCreateAdmin() {
    return const Center(
      child: CreateAdmin(),
    );
  }

  Widget _buildUserAccounts() {
    return const Center(
      child: AkaunPenggunaPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.2),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4A90E2).withOpacity(0.5),
                const Color(0xFF50E3C2).withOpacity(0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Text(
                  'Admin Panel',
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
              ),
              ..._drawerItems.map((item) => ListTile(
                leading: Icon(item['icon'], color: Colors.black),
                title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                selected: _selectedIndex == item['index'],
                selectedTileColor: Colors.blue.withOpacity(0.1),
                onTap: () {
                  _onItemTapped(item['index']);
                  Navigator.pop(context);
                },
              )),
              const Divider(color: Colors.white30),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient.map((color) => color.withOpacity(0.5)).toList(),
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildServiceRequests(),
            _buildCreateAdmin(),
            _buildUserAccounts(),
          ],
        ),
      ),
    );
  }
} 