import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../splash/splash_widget.dart';
import 'create_admin.dart';

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
    'Cipta Admin',
  ];

  final List<Map<String, dynamic>> _drawerItems = [
    {'icon': Icons.work, 'title': 'Permohonan Perkhidmatan', 'index': 0},
    {'icon': Icons.admin_panel_settings, 'title': 'Cipta Admin', 'index': 1}, 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.2),
              title: Text(
                _titles[_selectedIndex],
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
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
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Text(
                        'Admin Panel',
                        style: GoogleFonts.ubuntu(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    for (var item in _drawerItems)
                      _buildDrawerItem(
                        icon: item['icon'],
                        title: item['title'],
                        index: item['index'],
                        selectedIndex: _selectedIndex,
                        onTap: _onItemTapped,
                      ),
                  ],
                ),
              ),
              const Divider(color: Colors.white30),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _logout,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Log Keluar',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _selectedIndex == 0 ? _buildServiceRequests() : _buildCreateAdmin(),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required int selectedIndex,
    required Function(int) onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: selectedIndex == index
            ? Colors.blue.withOpacity(0.7)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selectedIndex == index ? Colors.white : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selectedIndex == index ? Colors.white : Colors.black,
          ),
        ),
        selected: selectedIndex == index,
        selectedColor: Colors.white,
        selectedTileColor: Colors.transparent,
        hoverColor: Colors.white.withOpacity(0.1),
        onTap: () {
          onTap(index);
          Navigator.pop(context);
        },
      ),
    );
  }
} 