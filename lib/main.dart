import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:myapp/Home.dart' as Home; // Optional alias if needed
import 'package:myapp/home.dart'; // Assuming this contains HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CCTV Security',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(), // Ensure this points to your desired home page
    );
  }
}
