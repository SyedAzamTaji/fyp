import 'package:flutter/material.dart';
import 'login.dart';
import 'custom_widgets.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomText(text: 'Select Role', fontSize: 28),
        const SizedBox(height: 40),
        CustomButton(
          text: "Login as Admin",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(role: 'admin'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: "Login as User",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(role: 'user'),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: isMobile
          ? Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/image123.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Center(child: content),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/image123.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Center(child: content),
                      const Positioned(
                        top: 20,
                        right: 20,
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image(
                            image: AssetImage('assets/logo123.jpg'),
                            fit: BoxFit.contain,
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
