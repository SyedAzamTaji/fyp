// import 'package:flutter/material.dart';
// import 'package:myapp/Home.dart';
// import 'Home.dart';

// class AreasFeedPage extends StatefulWidget {
//   const AreasFeedPage({super.key});

//   @override
//   _AreasFeedPageState createState() => _AreasFeedPageState();
// }

// class _AreasFeedPageState extends State<AreasFeedPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Areas Feed'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Cam 1'),
//             Tab(text: 'Cam 2'),
//             Tab(text: 'Cam 3'),
//           ],
//         ),
//       ),
//       body: Row(
//         children: [
//           // Left Side: Camera Feed
//           Expanded(
//             flex: 3,
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // Cam 1: Camera Recording Placeholder
//                 Center(
//                   child: Container(
//                     color: Colors.black,
//                     child: const Center(
//                       child: Text(
//                         'Camera 1 Recording',
//                         style: TextStyle(color: Colors.white, fontSize: 20),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Cam 2: No Camera Attached
//                 const Center(
//                   child: Text(
//                     'No camera attached',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                 ),
//                 // Cam 3: No Camera Attached
//                 const Center(
//                   child: Text(
//                     'No camera attached',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Right Side: Notifications and Alerts Panel
//           Expanded(
//             flex: 1,
//             child: Container(
//               color: Colors.grey[200],
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Notifications',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text('Critical: Unattended'),
//                   const SizedBox(height: 10),
//                   const Text('Object Detected'),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Critical Alerts',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text('Critical: Unattended'),
//                   const SizedBox(height: 10),
//                   const Text('Object Detected'),
//                   const Spacer(),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Log out logic
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const HomePage(),
//                         ),
//                       );
//                     },
//                     child: const Text('Log Out'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
