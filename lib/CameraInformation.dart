import 'package:flutter/material.dart';
import 'custom_widgets.dart'; // Import custom widgets

class CameraInformationPage extends StatefulWidget {
  const CameraInformationPage({Key? key}) : super(key: key);

  @override
  _CameraInformationPageState createState() => _CameraInformationPageState();
}

class _CameraInformationPageState extends State<CameraInformationPage> {
  // Controllers for the camera information fields
  final TextEditingController _cameraNameController = TextEditingController();
  final TextEditingController _cameraIdController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController _cameraAreaController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

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
          // Right-hand side (RHS) - Camera Information Form
          Expanded(
            flex: 1,
            child: Stack(
              children: <Widget>[
                // Centered Camera Information Form
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Custom text: 'Camera Information'
                        CustomText(text: 'Camera Information', fontSize: 28),
                        const SizedBox(height: 40),

                        // Camera Name Field
                        TextField(
                          controller: _cameraNameController,
                          decoration: const InputDecoration(
                              labelText: 'Camera Name'),
                        ),
                        const SizedBox(height: 20),

                        // Camera ID Field
                        TextField(
                          controller: _cameraIdController,
                          decoration: const InputDecoration(
                              labelText: 'Camera ID'),
                        ),
                        const SizedBox(height: 20),

                        // IP Address Field
                        TextField(
                          controller: _ipAddressController,
                          decoration: const InputDecoration(
                              labelText: 'IP Address'),
                        ),
                        const SizedBox(height: 20),

                        // Camera Area Field
                        TextField(
                          controller: _cameraAreaController,
                          decoration: const InputDecoration(
                              labelText: 'Camera Area'),
                        ),
                        const SizedBox(height: 20),

                        // Status Field
                        TextField(
                          controller: _statusController,
                          decoration: const InputDecoration(
                              labelText: 'Status'),
                        ),
                        const SizedBox(height: 40),

                        // Save Changes Button using CustomButton widget
                        CustomButton(
                          text: 'Save Changes',
                          onPressed: () {
                            // Get the values from the text fields
                            final cameraName = _cameraNameController.text
                                .trim();
                            final cameraId = _cameraIdController.text.trim();
                            final ipAddress = _ipAddressController.text.trim();
                            final cameraArea = _cameraAreaController.text
                                .trim();
                            final status = _statusController.text.trim();

                            // Example: Print the updated values
                            print('Camera Name: $cameraName');
                            print('Camera ID: $cameraId');
                            print('IP Address: $ipAddress');
                            print('Camera Area: $cameraArea');
                            print('Status: $status');
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Logo at the Top-Right Corner (same as UserSettingsPage)
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
