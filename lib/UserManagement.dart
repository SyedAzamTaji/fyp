import 'package:flutter/material.dart';
import 'package:myapp/AddUser.dart';
import 'package:myapp/RemoveUser.dart';
import 'custom_widgets.dart'; // Import custom widgets

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // Left-hand side (LHS) - Background Image
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image123.jpg'), // Background image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Right-hand side (RHS) - Content and Buttons
          Expanded(
            flex: 1,
            child: Stack(
              children: <Widget>[
                // Centered Buttons and Text
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Heading: User Management
                        CustomText(
                          text: 'User Management',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        SizedBox(height: 40),
                        // Add User Button
                        SizedBox(
                          width: 250, // Fixed width for both buttons (matching home page)
                          child: CustomButton(
                            text: 'Add User',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddUserPage(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Remove User Button
                        SizedBox(
                          width: 250, // Fixed width for both buttons (matching home page)
                          child: CustomButton(
                            text: 'Remove User',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RemoveUserPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Logo at the Top-Right Corner
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logo123.jpg'), // Logo image
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
