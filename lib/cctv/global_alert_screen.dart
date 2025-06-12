// global_alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'alert_model.dart';
import 'detection_provider.dart';

class GlobalAlertsScreen extends StatelessWidget {
  const GlobalAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Alerts Log"),
        actions: [
          // Add a button to clear all alerts globally
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Clear All Alerts",
            onPressed: () {
              // Show a confirmation dialog before clearing
              showDialog(
                context: context,
                builder: (BuildContext ctx) => AlertDialog(
                  title: const Text("Confirm Clear"),
                  content: const Text("Are you sure you want to delete all alerts from all cameras?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    TextButton(
                      child: const Text("Clear All", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Provider.of<DetectionProvider>(context, listen: false).clearAllGlobalAlerts();
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      // Use a Consumer to listen for changes in the DetectionProvider
      body: Consumer<DetectionProvider>(
        builder: (context, provider, child) {
          if (provider.globalAlerts.isEmpty) {
            return const Center(
              child: Text(
                "No alerts have been generated.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          // Use ListView.builder for an efficient, scrollable list
          return ListView.builder(
            itemCount: provider.globalAlerts.length,
            itemBuilder: (context, index) {
              final alert = provider.globalAlerts[index];
              final timeString =
                  "${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}:${alert.timestamp.second.toString().padLeft(2, '0')}";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: alert.color.withOpacity(0.1),
                elevation: 2,
                child: ListTile(
                  leading: Icon(alert.icon, color: alert.color, size: 24),
                  title: Text(alert.message, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "$timeString - From: ${alert.cameraName}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  // Add a trailing delete button for each individual alert
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    tooltip: "Delete Alert",
                    onPressed: () {
                      // Call the provider to remove the alert by its unique ID
                      provider.removeGlobalAlert(alert.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
