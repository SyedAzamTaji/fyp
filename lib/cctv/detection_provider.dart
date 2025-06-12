// detection_provider.dart
import 'package:flutter/foundation.dart';
import 'alert_model.dart';

class DetectionProvider extends ChangeNotifier {
  // This is now the single source of truth for all alerts from all cameras.
  final List<Alert> _globalAlerts = [];
  List<Alert> get globalAlerts => _globalAlerts;

  /// Adds a new alert to the global list and notifies listeners.
  void addGlobalAlert(Alert alert) {
    _globalAlerts.insert(0, alert); // Add new alerts to the top of the list
    if (_globalAlerts.length > 200) { // Keep the list from growing indefinitely
      _globalAlerts.removeLast();
    }
    notifyListeners(); // This tells all listening widgets to rebuild
  }

  /// Removes a specific alert from the global list using its unique ID.
  void removeGlobalAlert(String alertId) {
    _globalAlerts.removeWhere((alert) => alert.id == alertId);
    notifyListeners();
  }

  /// Clears all alerts from the global list.
  void clearAllGlobalAlerts() {
    _globalAlerts.clear();
    notifyListeners();
  }
}
