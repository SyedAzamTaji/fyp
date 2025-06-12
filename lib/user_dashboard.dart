import 'package:flutter/material.dart';
import 'package:myapp/AreasFeed.dart'; // Import AreasFeedPage
import 'package:myapp/Home.dart'; // Import HomePage
import 'package:myapp/UserSetting.dart'; // Import UserSettingsPage
import 'package:myapp/CameraInformation.dart';
import 'package:myapp/cctv/main_screen.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({Key? key}) : super(key: key); // Add key parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Match AdminDashboard style
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent, // Match AdminDashboard style
                    ),
                    child: Center(
                      child: Text(
                        'User Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.feed, color: Colors.blueAccent), // Added icon
                    title: const Text('Areas Feed'),
                    onTap: () {
                      // Navigate to Areas Feed Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.videocam, color: Colors.blueAccent), // Added icon
                    title: const Text('Camera Information'),
                    onTap: () {
                      // Navigate to Camera Information Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CameraInformationPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.blueAccent), // Added icon
                    title: const Text('Settings'),
                    onTap: () {
                      // Navigate to User Settings Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserSettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red), // Added icon
              title: const Text('Log out'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              ),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'User Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}