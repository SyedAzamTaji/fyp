import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/AdminSetting.dart';
import 'package:myapp/cctv/detection_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:myapp/Home.dart' as Home; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app with Provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => DetectionProvider(),
      child:  MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CCTV Security',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:
       Home.HomePage(), 
    );
  }
}
