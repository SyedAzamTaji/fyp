import 'package:flutter/material.dart';
import 'package:myapp/Home.dart';
import 'custom_widgets.dart'; // Import custom widgets

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({Key? key}) : super(key: key);

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cameraSettingsController = TextEditingController();

  bool _isPasswordVisible = false;

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
          // Right-hand side (RHS) - Settings Form
          Expanded(
            flex: 1,
            child: Stack(
              children: <Widget>[
                // Centered Settings Form
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Custom text: 'Admin Settings'
                        CustomText(text: 'Admin Settings', fontSize: 28),
                        SizedBox(height: 40),
                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Update Email'),
                        ),
                        const SizedBox(height: 20),
                        // Phone Number Field
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Update Phone Number'),
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Update Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Camera Settings Field
                        TextField(
                          controller: _cameraSettingsController,
                          decoration: const InputDecoration(labelText: 'Update Camera Settings'),
                        ),
                        const SizedBox(height: 40),
                        // Save Changes Button
                        CustomButton(
                          text: 'Save Changes',
                          onPressed: () {
                            // Add logic to save changes
                            final email = _emailController.text.trim();
                            final phone = _phoneController.text.trim();
                            final password = _passwordController.text.trim();
                            final cameraSettings = _cameraSettingsController.text.trim();

                            // Example: Print the updated values
                            print('Email: $email');
                            print('Phone: $phone');
                            print('Password: $password');
                            print('Camera Settings: $cameraSettings');
                          },
                        ),
                        const SizedBox(height: 20),
                        // Log Out Button

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