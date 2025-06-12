// alert_model.dart
import 'package:flutter/material.dart';

enum AlertLevel { info, warning, critical }

class Alert {
  final String id;
  final String message;
  final DateTime timestamp;
  final AlertLevel level;
  final String scenario;
  final String cameraName; // NEW: To identify the source camera

  Alert({
    required this.id,
    required this.message,
    required this.timestamp,
    this.level = AlertLevel.warning,
    required this.scenario,
    required this.cameraName, // NEW
  });

  IconData get icon {
    switch (level) {
      case AlertLevel.info:
        return Icons.info_outline;
      case AlertLevel.warning:
        return Icons.warning_amber_rounded;
      case AlertLevel.critical:
        return Icons.error_outline;
    }
  }

  Color get color {
    switch (level) {
      case AlertLevel.info:
        return Colors.blue;
      case AlertLevel.warning:
        return Colors.orange.shade700;
      case AlertLevel.critical:
        return Colors.red.shade700;
    }
  }
}
