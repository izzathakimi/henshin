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
import 'request_service_page/request_service_page_widget.dart';
import 'service_inprogress_page/service_inprogress_page_widget.dart';
import 'community_forum/community_forum.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CommunityForum(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Henshin'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
           
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Job Application'),
              onTap: () => _navigateTo(const JobApplicationPageWidget()),
            ),
            
            // ListTile(
            //   leading: const Icon(Icons.create),
            //   title: const Text('Create Project'),
            //   onTap: () => _navigateTo(const CreateProjectPageWidget()),
            // ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Job Proposals'),
              onTap: () => _navigateTo(const JobProposalsPageWidget()),
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Request Service'),
              onTap: () => _navigateTo(const RequestServicePageWidget()),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Service In Progress'),
              onTap: () => _navigateTo(const ServiceInprogressPageWidget()),
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) { // Community Forum index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CommunityForum()),
      );
    } else {
      Navigator.of(context).pop(); // Close the drawer
    }
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).pop(); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
