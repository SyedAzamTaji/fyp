import 'package:flutter/material.dart';
import 'package:myapp/Home.dart';
import 'custom_widgets.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({Key? key}) : super(key: key);

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cameraSettingsController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;

          return isWideScreen
              ? Row(
                  children: <Widget>[
                    // Left Side: Background Image
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/image123.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Right Side: Settings Form
                    Expanded(
                      flex: 1,
                      child: _buildSettingsForm(),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/image123.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: _buildSettingsForm(),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildSettingsForm() {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: 'Admin Settings', fontSize: 28),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Update Email'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Update Phone Number'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Update Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                  TextField(
                    controller: _cameraSettingsController,
                    decoration: const InputDecoration(labelText: 'Update Camera Settings'),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Save Changes',
                    onPressed: () {
                      print('Email: ${_emailController.text.trim()}');
                      print('Phone: ${_phoneController.text.trim()}');
                      print('Password: ${_passwordController.text.trim()}');
                      print('Camera Settings: ${_cameraSettingsController.text.trim()}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              'assets/logo123.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
