import 'package:flutter/material.dart';
import 'custom_widgets.dart'; // Import the custom widgets

class RemoveCameraPage extends StatelessWidget {
  final TextEditingController _cameraIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Remove Camera',
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent, // Changed to red for distinction
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
                      text: 'Remove Camera',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent, // Changed to red for distinction
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
                    // Remove Camera Button
                    CustomButton(
                      text: 'Remove Camera',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Camera Removed!')),
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