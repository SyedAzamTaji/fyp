import 'package:flutter/material.dart';
import 'package:myapp/AddCamera.dart';
import 'package:myapp/RemoveCamera.dart';
import 'custom_widgets.dart'; // Import custom widgets

class CameraManagementPage extends StatelessWidget {
  const CameraManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image123.jpg'), 
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
                        // Heading: Camera Management
                        CustomText(
                          text: 'Camera Management',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        SizedBox(height: 40),
                        // Add Camera Button
                        SizedBox(
                          width: 250, // Fixed width for both buttons
                          child: CustomButton(
                            text: 'Add Camera',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCameraPage(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Remove Camera Button
                        SizedBox(
                          width: 250, // Fixed width for both buttons
                          child: CustomButton(
                            text: 'Remove Camera',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RemoveCameraPage(),
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