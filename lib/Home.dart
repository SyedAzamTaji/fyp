import 'package:flutter/material.dart';
import 'package:myapp/login.dart';
import 'package:myapp/Register.dart';
import 'package:myapp/role_selection_page.dart';
import 'custom_widgets.dart';
import 'package:myapp/Home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth >= 600;

        return Scaffold(
          body: isWide
              ? Row(
                  children: [
                    // Left side (image)
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
                    // Right side (content)
                    Expanded(
                      flex: 1,
                      child: _buildContent(context),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.asset(
                        'assets/image123.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Overlay content
                    Container(
                      color: Colors.black.withOpacity(0.6), // semi-transparent overlay for text readability
                      child: _buildContent(context),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomText(text: 'Welcome To', fontSize: 28),
              const CustomText(text: 'CCTV Security', fontSize: 28),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Login',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RoleSelectionPage()
                    // LoginPage()
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Register',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Logo Top-Right
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logo123.jpg'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}