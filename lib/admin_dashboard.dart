import 'package:flutter/material.dart';
import 'package:myapp/home.dart' as Home;
import 'package:myapp/Home.dart' as HomeAlt;
import 'package:myapp/CameraManagement.dart';
import 'package:myapp/UserManagement.dart' as UserManagement;
import 'package:myapp/AdminSetting.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Keep AppBar color as blue
        title: const Text('Admin Dashboard'),
        centerTitle: true, // Center the title
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
                      color: Colors.blue, // Match UserDashboard style
                    ),
                    child: Center(
                      child: Text(
                        'Admin Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.camera_alt, color: Colors.blue), // Added icon
                    title: const Text('Camera Management'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraManagementPage(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.blue), // Added icon
                    title: const Text('User Management'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagement.UserManagementPage(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.blue), // Added icon
                    title: const Text('Settings'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminSettingsPage(),
                      ),
                    ),
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
                  builder: (context) => const Home.HomePage(),
                ),
              ),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}