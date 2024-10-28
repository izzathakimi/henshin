import 'package:flutter/material.dart';
import 'home_screen/home_screen.dart';
import 'profile_screen/profile.dart';
import 'profile_screen/profile_screen.dart';
import 'community_forum/community_forum.dart';
import 'chat/chat_screen.dart';
// Import the new pages
import 'job_application_page/job_application_widget.dart';
// import 'job_application_page2/job_application_page2_widget.dart';
// import 'create_project_page/create_project_page_widget.dart';
// import 'job_proposals_page/job_proposals_page_widget.dart';
import 'job_proposals_page/job_proposals_page_widget.dart';
import 'request_service_page1/request_service_page1_widget.dart';
import 'service_inprogress_page/service_inprogress_page_widget.dart';
import 'common/henshin_theme.dart';
import 'request_history/request_history_widget.dart';
import 'package:google_fonts/google_fonts.dart';
// Add this import at the top with other imports
import 'dart:ui';

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
    const ProfileScreen(),  // Added ProfileScreen
    const JobApplicationPageWidget(),
    const JobProposalsPageWidget(),
    const RequestServicePage1Widget(),
    const ServiceInprogressPageWidget(),
    const RequestHistoryWidget(),
  ];

  final List<String> _titles = [
    'Home',
    'Community Forum',
    'Chat',
    'Profile',
    'Create Post',  // Added corresponding title
    'Job Application',
    'Job Proposals',
    'Request Service',
    'Service In Progress',
    'Request History',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // if (index == 1) { // Community Forum index
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const CommunityForum()),
    //   );
    // } else {
    //   Navigator.of(context).pop(); // Close the drawer
    // }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required int selectedIndex,
    required Function(int) onTap,
    Color textColor = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),  // This makes it pill-shaped
        color: selectedIndex == index ? Colors.blue.withOpacity(0.7) : Colors.transparent,
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
        // Remove the selectedTileColor since we're handling the background in the Container
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Text(
                  'Henshin.',  // Changed from 'Menu' to 'Henshin.'
                  style: GoogleFonts.ubuntu(  // Using GoogleFonts.ubuntu
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.person,
                title: 'Profile',
                index: 3,  // Changed to match ProfileScreen
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
                textColor: Colors.white,
              ),
              const Divider(color: Colors.white30),
              _buildDrawerItem(
                icon: Icons.work,
                title: 'Gig Application',
                index: 4,  // Changed from 4 to 5
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
                textColor: Colors.white,
              ),
              _buildDrawerItem(
                icon: Icons.description,
                title: 'Gig Proposals',
                index: 5,  // Changed from 5 to 6
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              _buildDrawerItem(
                icon: Icons.build,
                title: 'Request Service',
                index: 6,  // Changed from 6 to 7
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              _buildDrawerItem(
                icon: Icons.timer,
                title: 'Service In Progress',
                index: 7,  // Changed from 7 to 8
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              _buildDrawerItem(
                icon: Icons.history,
                title: 'Request History',
                index: 8,  // Changed from 8 to 9
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
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
              color: Colors.white.withOpacity(0.2),  // Very subtle white background
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
              showSelectedLabels: false,    // Add this line
              showUnselectedLabels: false,  // Add this line
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
