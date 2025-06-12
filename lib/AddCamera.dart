import 'package:flutter/material.dart';
import 'custom_widgets.dart'; // Import the custom widgets

class AddCameraPage extends StatelessWidget {
  final TextEditingController _cameraNameController = TextEditingController();
  final TextEditingController _cameraIdController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Add Camera',
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    CustomText(
                      text: 'Add New Camera',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 20),
                    // Camera Name TextField
                    TextField(
                      controller: _cameraNameController,
                      decoration: InputDecoration(
                        labelText: 'Camera Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.camera_alt),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Camera ID TextField
                    TextField(
                      controller: _cameraIdController,
                      decoration: InputDecoration(
                        labelText: 'Camera ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.videocam),
                      ),
                    ),
                    SizedBox(height: 20),
                    // IP Address TextField
                    TextField(
                      controller: _ipAddressController,
                      decoration: InputDecoration(
                        labelText: 'IP Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.network_check),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Add Camera Button
                    CustomButton(
                      text: 'Add Camera',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Camera Added!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}