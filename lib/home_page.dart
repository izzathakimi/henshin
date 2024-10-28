import 'package:flutter/material.dart';
import 'home_screen/home_screen.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CommunityForum(),
    const ChatScreen(),
    const ProfileScreen(),
    const JobApplicationPageWidget(),
    const JobProposalsPageWidget(),
    const RequestServicePage1Widget(),
    const ServiceInprogressPageWidget(),
  ];

  final List<String> _titles = [
    'Home',
    'Community Forum',
    'Chat',
    'Profile',
    'Job Application',
    'Job Proposals',
    'Request Service',
    'Service In Progress',
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
    return ListTile(
      leading: Icon(
        icon,
        color: selectedIndex == index ? HenshinTheme.primaryColor : null,
      ),
      title: Text(title),
      selected: selectedIndex == index,
      selectedColor: HenshinTheme.primaryColor,
      selectedTileColor: HenshinTheme.primaryColor.withOpacity(0.1),
      hoverColor: HenshinTheme.primaryColor.withOpacity(0.05),
      onTap: () {
        onTap(index);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: HenshinTheme.primaryGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent, // Make header transparent to show gradient
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.person,
                title: 'Profile',
                index: 3,
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
                textColor: Colors.white, // Add white text for contrast
              ),
              const Divider(color: Colors.white30), // Light divider
              _buildDrawerItem(
                icon: Icons.work,
                title: 'Job Application',
                index: 4,
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
                textColor: Colors.white,
              ),
              _buildDrawerItem(
                icon: Icons.description,
                title: 'Job Proposals',
                index: 5,
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              _buildDrawerItem(
                icon: Icons.build,
                title: 'Request Service',
                index: 6,
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              _buildDrawerItem(
                icon: Icons.timer,
                title: 'Service In Progress',
                index: 7,
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ],
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex < 3 ? _selectedIndex : 0,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
