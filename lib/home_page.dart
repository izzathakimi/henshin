import 'package:flutter/material.dart';
import 'home_screen/home_screen.dart';
import 'profile_screen/profile.dart';
import 'community_forum/community_forum.dart';
import 'chat/chat_screen.dart';
import 'job_application_page/job_application_widget.dart';
import 'job_application_page2/job_application_page2_widget.dart';
import 'job_proposals_page2/job_proposals_page2_widget.dart';
import 'job_proposals_page/job_proposals_page_widget.dart';
import 'request_service_page1/request_service_page1_widget.dart';
import 'service_inprogress_page/service_inprogress_page_widget.dart';
import 'request_history/request_history_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'dart:ui';
import 'splash/splash_widget.dart';

class HomePage extends StatefulWidget {
  final int? initialIndex;
  const HomePage({super.key, this.initialIndex});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const CommunityForum(),
    const ChatScreen(),
    const Profile(),
    const JobApplicationPageWidget(),
    const JobProposalsPageWidget(),
    const RequestServicePage1Widget(),
    const ServiceInprogressPageWidget(),
    const RequestHistoryWidget(),
    const JobApplicationPage2Widget(),
    const JobProposalsPage2Widget(),

  ];

  final List<String> _titles = [
    'Halaman Utama',
    'Forum Komuniti',
    'Ruang Pesan',
    'Halaman Profil',
    'Kerja Tersedia',
    'Permohonan Kerja',
    'Tawar Pekerjaan',
    'Servis dalam Proses',
    'Senarai Pekerjaan Yang Ditawarkan',
  ];

  final List<Map<String, dynamic>> _drawerItems = [
    {'icon': Icons.person, 'title': 'Halaman Profil', 'index': 3},
    {'icon': Icons.work, 'title': 'Kerja Tersedia', 'index': 4},
    {'icon': Icons.description, 'title': 'Permohonan Kerja', 'index': 5},
    {'icon': Icons.build, 'title': 'Tawar Pekerjaan', 'index': 6},
    {'icon': Icons.timer, 'title': 'Servis Dalam Proses', 'index': 7},
    {'icon': Icons.history, 'title': 'Senarai Pekerjaan Yang Ditawarkan', 'index': 8},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => SplashWidget()), // Redirect to SplashWidget
      );
    } catch (e) {
      // Handle error (e.g., show a Snackbar)
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
                        'RuralHub.',
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
              // Log Keluar Button with Hover Effect
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _logout, // Call the logout function
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red),
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex < 3 ? _selectedIndex : 0,
              selectedItemColor: Colors.blue.withOpacity(0.7),
              unselectedItemColor: Colors.black,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
