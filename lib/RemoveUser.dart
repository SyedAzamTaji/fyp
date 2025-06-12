import 'package:flutter/material.dart';
import 'custom_widgets.dart'; // Import the custom widgets

class RemoveUserPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Remove User',
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
                      text: 'Remove User',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent, // Changed to red for distinction
                    ),
                    SizedBox(height: 20),
                    // Email TextField
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Remove User Button
                    CustomButton(
                      text: 'Remove User',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('User Removed!')),
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