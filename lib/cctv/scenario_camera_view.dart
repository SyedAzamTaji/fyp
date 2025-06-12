// scenario_camera_view.dart
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
// **FIXED**: Use the web-specific 'ui_web' library for platformViewRegistry
import 'dart:ui_web' as ui_web;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:myapp/cctv/global_alert_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'alert_model.dart';
import 'detection_provider.dart';


enum ScenarioType {
  cam1_unattended_luggage,
  cam2_boarding_lanes,
  cam3_restricted_zone,
}

class ScenarioCameraView extends StatefulWidget {
  final ScenarioType scenarioType;
  final String cameraName;

  const ScenarioCameraView({super.key, required this.scenarioType, required this.cameraName});

  @override
  State<ScenarioCameraView> createState() => _ScenarioCameraViewState();
}

class _ScenarioCameraViewState extends State<ScenarioCameraView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final html.VideoElement _videoElement = html.VideoElement();
  bool _isStreaming = false, _isDetecting = false;
  Timer? _detectionTimer;
  List<Map<String, dynamic>> _currentFrameDetections = [];
  int _videoWidth = 640, _videoHeight = 480;
  String? _videoViewType, _errorMessage;
  final Uuid _uuid = const Uuid();

  // State for advanced spam prevention
  final List<Map<String, dynamic>> _recentAlertHistory = [];

  // Scenario-specific state
  Map<String, DateTime> _unattendedLuggageTimers = {};
  final Duration _unattendedThreshold = const Duration(seconds: 10);
  final List<Rect> _boardingLanes = [const Rect.fromLTWH(0.1, 0.2, 0.25, 0.6), const Rect.fromLTWH(0.375, 0.2, 0.25, 0.6), const Rect.fromLTWH(0.65, 0.2, 0.25, 0.6)];
  List<int> _lanePersonCounts = [0, 0, 0];
  final Rect _restrictedZone = const Rect.fromLTWH(0, 0, 1, 1);

  // New state for "no person" luggage scenario
  DateTime? _noPersonSightingStartTime;
  DateTime? _noPersonLuggageCooldownUntil;


  @override
  void initState() {
    super.initState();
    _videoViewType = 'video-view-${widget.cameraName.replaceAll(" ", "_")}-${_videoElement.hashCode}';
    // **FIXED**: Use the correct `ui_web` prefix here
    ui_web.platformViewRegistry.registerViewFactory(
        _videoViewType!, (int viewId) => _videoElement..style.width='100%'..style.height='100%'..style.objectFit='cover');
    _initCamera();
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _stopCameraStream();
    _videoElement.remove();
    super.dispose();
  }

  // Helpers to safely cast num to double
  double _toDouble(dynamic val) => (val as num).toDouble();
  List<double> _getDoublesFromBox(dynamic boxData) {
    if (boxData == null || boxData is! List) return [0.0, 0.0, 0.0, 0.0];
    return boxData.map((e) => _toDouble(e)).toList();
  }

  Future<void> _initCamera() async {
    setState(() { _errorMessage = null; });
    try {
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({'video': { 'facingMode': 'environment', 'width': {'ideal': 1280}, 'height': {'ideal': 720} }});
      _videoElement.srcObject = stream;
      _videoElement.autoplay = true; _videoElement.muted = true;
      _videoElement.onLoadedMetadata.listen((_) {
        if (!mounted) return;
        setState(() {
          _videoWidth = _videoElement.videoWidth ?? _videoWidth;
          _videoHeight = _videoElement.videoHeight ?? _videoHeight;
          _isStreaming = true; _errorMessage = null;
        });
        _startDetectionLoop();
      });
      _videoElement.onError.listen((_) {
        if (!mounted) return;
        setState(() { _isStreaming = false; _errorMessage = "Video stream error for ${widget.cameraName}."; });
        _stopCameraStream();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isStreaming = false; _errorMessage = "Failed to access camera for ${widget.cameraName}: Check permissions."; });
    }
  }

  void _stopCameraStream() {
    _detectionTimer?.cancel();
    _videoElement.srcObject?.getTracks().forEach((track) => track.stop());
    _videoElement.srcObject = null;
    if (mounted) setState(() { _isStreaming = false; _isDetecting = false; });
  }

  Future<Uint8List?> _captureFrame() async {
    if (!_isStreaming || _videoWidth == 0 || _videoHeight == 0) return null;
    final canvas = html.CanvasElement(width: _videoWidth, height: _videoHeight);
    final ctx = canvas.getContext('2d') as html.CanvasRenderingContext2D;
    ctx.drawImage(_videoElement, 0, 0);
    try {
      final blob = await canvas.toBlob('image/jpeg', 0.8);
      if (blob == null) return null;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);
      await reader.onLoad.first;
      return reader.result as Uint8List?;
    } catch (e) { return null; }
  }

  void _startDetectionLoop() {
    _detectionTimer?.cancel();
    if (!_isStreaming) return;
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) async {
      if (!mounted || !_isStreaming || _isDetecting) { if (!_isStreaming && mounted) timer.cancel(); return; }
      setState(() { _isDetecting = true; });
      final frameBytes = await _captureFrame();
      if (frameBytes != null) await _sendFrameForDetection(frameBytes);
      if(mounted) setState(() { _isDetecting = false; });
    });
  }

  Future<void> _sendFrameForDetection(Uint8List frameBytes) async {
    try {
      final uri = Uri.parse('http://192.168.1.110:8000/detect'); // YOUR PYTHON API URL
      var request = http.MultipartRequest('POST', uri)..files.add(http.MultipartFile.fromBytes('file', frameBytes, filename: 'frame.jpg', contentType: MediaType('image', 'jpeg')));
      final response = await request.send().timeout(const Duration(seconds: 5));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(await response.stream.bytesToString());
        if (data.containsKey('detections')) {
          final rawDetections = List<Map<String, dynamic>>.from(data['detections']);
          setState(() { _currentFrameDetections = rawDetections; _errorMessage = null; });
          _processDetectionsForScenario(rawDetections);
        } else if (data.containsKey('error')) { setState(() { _errorMessage = "API Error: ${data['error']}"; _currentFrameDetections = []; }); }
      } else { setState(() { _errorMessage = "API Error (${response.statusCode}) for ${widget.cameraName}."; _currentFrameDetections = []; }); }
    } catch (e) { if (!mounted) return; setState(() { _errorMessage = "Network error for ${widget.cameraName}."; _currentFrameDetections = []; }); }
  }

  void _addAlert(String message, String scenarioName, {AlertLevel level = AlertLevel.warning}) {
    if (!mounted) return;
    final alert = Alert(id: _uuid.v4(), message: message, timestamp: DateTime.now(), level: level, scenario: scenarioName, cameraName: widget.cameraName);
    Provider.of<DetectionProvider>(context, listen: false).addGlobalAlert(alert);
  }

  void _processDetectionsForScenario(List<Map<String, dynamic>> detections) {
    for (var det in detections) { _handleGeneralAlerts(det); }
    switch (widget.scenarioType) {
      case ScenarioType.cam1_unattended_luggage: _handleUnattendedLuggage(detections); break;
      case ScenarioType.cam2_boarding_lanes: _handleBoardingLanes(detections); break;
      case ScenarioType.cam3_restricted_zone: _handleRestrictedZone(detections); break;
    }
  }

  void _handleGeneralAlerts(Map<String, dynamic> detection) {
    final String label = detection['label']?.toString().toLowerCase() ?? '';
    final List<String> generalLabels = ['spillage', 'cracks', 'garbage_overflow'];
    if (!generalLabels.contains(label)) return;

    _recentAlertHistory.removeWhere((a) => DateTime.now().difference(a['timestamp']).inMinutes >= 2);

    final box = _getDoublesFromBox(detection['box']);
    final double centerX = (box[0] + box[2]) / 2;
    final double centerY = (box[1] + box[3]) / 2;

    bool shouldSuppress = false;
    for (var recent in _recentAlertHistory) {
      if (recent['label'] == label) {
        final double oldX = _toDouble(recent['x']);
        final double oldY = _toDouble(recent['y']);
        final distance = math.sqrt(math.pow(centerX - oldX, 2) + math.pow(centerY - oldY, 2));
        if (distance < 100) { shouldSuppress = true; break; }
      }
    }

    if (!shouldSuppress) {
      _addAlert("${label.replaceAll('_', ' ').capitalize()} detected.", "General Detection", level: AlertLevel.info);
      _recentAlertHistory.add({'label': label, 'x': centerX, 'y': centerY, 'timestamp': DateTime.now()});
    }
  }

  void _handleUnattendedLuggage(List<Map<String, dynamic>> detections) {
    final persons = detections.where((d) => d['label'] == 'person').toList();
    final luggages = detections.where((d) => d['label'] == 'luggage').toList();

    if (persons.isEmpty && luggages.isNotEmpty) {
      if (_noPersonLuggageCooldownUntil != null && DateTime.now().isBefore(_noPersonLuggageCooldownUntil!)) {
        return;
      }
      if (_noPersonSightingStartTime == null) {
        _noPersonSightingStartTime = DateTime.now();
      } else {
        if (DateTime.now().difference(_noPersonSightingStartTime!) > const Duration(seconds: 20)) {
          _addAlert("Unattended Luggage (No Persons Present)", "Unattended Luggage", level: AlertLevel.critical);
          _noPersonLuggageCooldownUntil = DateTime.now().add(const Duration(minutes: 1));
          _noPersonSightingStartTime = null;
        }
      }
    } else {
      _noPersonSightingStartTime = null;
    }

    Map<String, Map<String, dynamic>> currentFrameLuggageMap = {};
    for (var l in luggages) {
      final box = _getDoublesFromBox(l['box']);
      String luggageId = "${box[0].toInt()}_${box[1].toInt()}";
      currentFrameLuggageMap[luggageId] = l;
      bool isAttended = false;
      for (var p in persons) {
        if (_isLuggageNearPerson(l, p)) { isAttended = true; break; }
      }
      if (isAttended) {
        _unattendedLuggageTimers.remove(luggageId);
      } else {
        if (!_unattendedLuggageTimers.containsKey(luggageId)) {
          _unattendedLuggageTimers[luggageId] = DateTime.now();
        } else {
          if (DateTime.now().difference(_unattendedLuggageTimers[luggageId]!) > _unattendedThreshold) {
            final alertMessage = "Unattended Luggage (ID: $luggageId)";
            _addAlert(alertMessage, "Unattended Luggage", level: AlertLevel.critical);
            _unattendedLuggageTimers.remove(luggageId);
          }
        }
      }
    }
    _unattendedLuggageTimers.removeWhere((id, _) => !currentFrameLuggageMap.containsKey(id));
  }

  bool _isLuggageNearPerson(Map<String, dynamic> luggage, Map<String, dynamic> person) {
    final lBox = _getDoublesFromBox(luggage['box']);
    final pBox = _getDoublesFromBox(person['box']);
    final lCenterX = (lBox[0] + lBox[2]) / 2;
    final lCenterY = (lBox[1] + lBox[3]) / 2;
    final pCenterX = (pBox[0] + pBox[2]) / 2;
    final pCenterY = (pBox[1] + pBox[3]) / 2;
    final distance = math.sqrt(math.pow(lCenterX - pCenterX, 2) + math.pow(lCenterY - pCenterY, 2));
    final pWidth = pBox[2] - pBox[0];
    final lWidth = lBox[2] - lBox[0];
    return distance < (pWidth + lWidth) * 0.75;
  }

  void _handleBoardingLanes(List<Map<String, dynamic>> detections) {
    List<int> currentLaneCounts = List.filled(_boardingLanes.length, 0);
    for (var det in detections) {
      if (det['label'] == 'person') {
        final box = _getDoublesFromBox(det['box']);
        final personCenterX = ((box[0] + box[2]) / 2) / _videoWidth;
        final personCenterY = ((box[1] + box[3]) / 2) / _videoHeight;
        for (int i = 0; i < _boardingLanes.length; i++) {
          if (_boardingLanes[i].contains(Offset(personCenterX, personCenterY))) {
            currentLaneCounts[i]++;
            break;
          }
        }
      }
    }
    if (mounted) setState(() { _lanePersonCounts = currentLaneCounts; });

    for (int i = 0; i < currentLaneCounts.length; i++) {
      for (int j = i + 1; j < currentLaneCounts.length; j++) {
        if ((currentLaneCounts[i] - currentLaneCounts[j]).abs() >= 2) {
          final alertMessage = "Uneven traffic detected.";
          // Check history to prevent spam
          if (!_recentAlertHistory.any((a) => a['message'] == alertMessage && DateTime.now().difference(a['timestamp']).inSeconds < 30)) {
            String allLaneCounts = "Counts: ";
            for (int k = 0; k < currentLaneCounts.length; k++) {
              allLaneCounts += "L${k + 1}: ${currentLaneCounts[k]}${k == currentLaneCounts.length - 1 ? '' : ', '}";
            }
            _addAlert("$alertMessage $allLaneCounts", "Boarding Lanes", level: AlertLevel.warning);
            _recentAlertHistory.add({'message': alertMessage, 'timestamp': DateTime.now()});
          }
          return;
        }
      }
    }
  }

  void _handleRestrictedZone(List<Map<String, dynamic>> detections) {
    bool unauthorizedPersonInZone = detections.any((d) => d['label'] == 'person' && _isDetectionInZone(d, _restrictedZone));
    bool authorizedPersonInZone = detections.any((d) => d['label'] == 'authorized_personnel' && _isDetectionInZone(d, _restrictedZone));

    if (unauthorizedPersonInZone && !authorizedPersonInZone) {
      final alertMessage = "Restricted zone access by unauthorized person.";
      if (!_recentAlertHistory.any((a) => a['message'] == alertMessage && DateTime.now().difference(a['timestamp']).inSeconds < 30)) {
        _addAlert(alertMessage, "Restricted Zone", level: AlertLevel.critical);
        _recentAlertHistory.add({'message': alertMessage, 'timestamp': DateTime.now()});
      }
    }
  }

  bool _isDetectionInZone(Map<String, dynamic> detection, Rect zone) {
    final box = _getDoublesFromBox(detection['box']);
    final centerX = ((box[0] + box[2]) / 2) / _videoWidth;
    final centerY = ((box[1] + box[3]) / 2) / _videoHeight;
    return zone.contains(Offset(centerX, centerY));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      children: [
        Expanded(flex: 3, child: Container(color: Colors.black, child: LayoutBuilder(
          builder: (context, constraints) {
            final double scaleX = _videoWidth > 0 ? constraints.maxWidth / _videoWidth : 0;
            final double scaleY = _videoHeight > 0 ? constraints.maxHeight / _videoHeight : 0;
            return Stack(fit: StackFit.expand, children: [
              if (_isStreaming && _videoViewType != null) SizedBox(width: constraints.maxWidth, height: constraints.maxHeight, child: HtmlElementView(viewType: _videoViewType!)),
              if (!_isStreaming) Center(child: _errorMessage != null
                  ? Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center))
                  : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Colors.white), SizedBox(height: 10), Text("Initializing camera...")])),
              if (scaleX > 0 && scaleY > 0) ..._currentFrameDetections.map((d) => _buildBoundingBox(d, scaleX, scaleY)).toList(),
              if (scaleX > 0 && scaleY > 0) ..._buildScenarioSpecificOverlays(constraints),
              if (_errorMessage != null && _isStreaming) Positioned(bottom: 10, left: 10, right: 10, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: Colors.black.withOpacity(0.7),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.yellowAccent, fontSize: 12), textAlign: TextAlign.center))),
            ]);
          },
        ))),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalAlertsScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade300)), color: Colors.blueGrey[50]),
              child: Consumer<DetectionProvider>(
                builder: (context, provider, child) {
                  final localAlerts = provider.globalAlerts.where((a) => a.cameraName == widget.cameraName).toList();
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${widget.cameraName} Alerts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
                        const Icon(Icons.open_in_new, color: Colors.grey, size: 18),
                      ],
                    )),
                    const Divider(height: 1),
                    Expanded(
                      child: localAlerts.isEmpty
                          ? const Center(child: Text("No alerts for this camera.", style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                        itemCount: localAlerts.length > 5 ? 5 : localAlerts.length,
                        itemBuilder: (context, index) {
                          final alert = localAlerts[index];
                          final timeString = "${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}";
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 2), color: alert.color.withOpacity(0.1), elevation: 0,
                            child: ListTile(
                              dense: true,
                              leading: Icon(alert.icon, color: alert.color, size: 18),
                              title: Text(alert.message, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              subtitle: Text(timeString, style: const TextStyle(fontSize: 10)),
                            ),
                          );
                        },
                      ),
                    ),
                  ]);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildScenarioSpecificOverlays(BoxConstraints constraints) {
    List<Widget> overlays = [];
    switch (widget.scenarioType) {
      case ScenarioType.cam2_boarding_lanes:
        for (int i = 0; i < _boardingLanes.length; i++) {
          final laneRect = Rect.fromLTWH(
            _boardingLanes[i].left * constraints.maxWidth, _boardingLanes[i].top * constraints.maxHeight,
            _boardingLanes[i].width * constraints.maxWidth, _boardingLanes[i].height * constraints.maxHeight,
          );
          overlays.add(Positioned.fromRect(rect: laneRect, child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.blue.withOpacity(0.7), width: 2)),
            child: Align(alignment: Alignment.topCenter, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), color: Colors.blue.withOpacity(0.7),
              child: Text("Lane ${i+1}: ${_lanePersonCounts[i]}", style: const TextStyle(color: Colors.white, fontSize: 12)),
            )),
          )));
        }
        break;
      case ScenarioType.cam3_restricted_zone:
        final zoneRect = Rect.fromLTWH(
          _restrictedZone.left * constraints.maxWidth, _restrictedZone.top * constraints.maxHeight,
          _restrictedZone.width * constraints.maxWidth, _restrictedZone.height * constraints.maxHeight,
        );
        overlays.add(Positioned.fromRect(rect: zoneRect, child: Container(
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), border: Border.all(color: Colors.red.withOpacity(0.7), width: 2)),
          child: const Align(alignment: Alignment.topLeft, child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Text("RESTRICTED", style: TextStyle(color: Colors.white, backgroundColor: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          )),
        )));
        break;
      case ScenarioType.cam1_unattended_luggage: break;
    }
    return overlays;
  }

  Widget _buildBoundingBox(Map<String, dynamic> detection, double scaleX, double scaleY) {
    final box = _getDoublesFromBox(detection['box']);
    final label = detection['label'] ?? 'Unknown';
    final confidence = _toDouble(detection['confidence']);

    if (scaleX <= 0 || scaleY <= 0 || box[2] <= box[0] || box[3] <= box[1]) return const SizedBox.shrink();
    final left = box[0] * scaleX; final top = box[1] * scaleY;
    final width = (box[2] - box[0]) * scaleX; final height = (box[3] - box[1]) * scaleY;
    Color boxColor = Colors.redAccent;
    if (label == 'authorized_personnel') boxColor = Colors.greenAccent;
    if (label == 'luggage') boxColor = Colors.amberAccent;
    if (['spillage', 'broken_tiles', 'filled_garbage_bins'].contains(label)) boxColor = Colors.cyanAccent;
    return Positioned(left: left, top: top, width: width, height: height, child: Container(
      decoration: BoxDecoration(border: Border.all(color: boxColor, width: 1.5)),
      child: Align(alignment: Alignment.topLeft, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1), color: boxColor.withOpacity(0.7),
        child: Text("$label ${(confidence * 100).toStringAsFixed(0)}%",
            style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
      )),
    ));
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? "" : "${this[0].toUpperCase()}${substring(1).replaceAll('_', ' ')}";
}
