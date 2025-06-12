import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CCTV Monitoring System'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.videocam), text: "Cam 1"),
            Tab(icon: Icon(Icons.group_work), text: "Cam 2"),
            Tab(icon: Icon(Icons.security), text: "Cam 3"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // Prevent tabs from being disposed when not active to maintain state (e.g., video stream)
        // This can be resource-intensive. Consider if this is desired or if state needs saving/restoring.
        // For simplicity now, we keep them alive.
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to change tabs
        children: const [
          // ScenarioCameraView(scenarioType: ScenarioType.cam1_unattended_luggage, cameraName: "Camera 1"),
          // ScenarioCameraView(scenarioType: ScenarioType.cam2_boarding_lanes, cameraName: "Camera 2"),
          // ScenarioCameraView(scenarioType: ScenarioType.cam3_restricted_zone, cameraName: "Camera 3"),
        ],
      ),
    );
  }
}