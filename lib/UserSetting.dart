import 'package:flutter/material.dart';
import 'package:myapp/Home.dart';
import 'custom_widgets.dart'; // Import custom widgets

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({Key? key}) : super(key: key);

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cameraSettingsController = TextEditingController(); // Added for camera settings

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
                        // Custom text: 'User Settings'
                        CustomText(text: 'User Settings', fontSize: 28),
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
                        const SizedBox(height: 40),
                        // Save Changes Button using CustomButton widget
                        CustomButton(
                          text: 'Save Changes',
                          onPressed: () {
                            // Add logic to save changes
                            final email = _emailController.text.trim();
                            final phone = _phoneController.text.trim();
                            final password = _passwordController.text.trim();

                            // Example: Print the updated values
                            print('Email: $email');
                            print('Phone: $phone');
                            print('Password: $password');
                          },
                        ),
                        const SizedBox(height: 20),
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
