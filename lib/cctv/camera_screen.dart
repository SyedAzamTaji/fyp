

// camera_screen.dart
import 'dart:async';
import 'dart:convert'; // For json decoding
import 'dart:html'; // Provides Blob, CanvasElement, VideoElement, etc. for web
import 'dart:typed_data'; // For Uint8List
import 'dart:ui' as ui; // For platformViewRegistry

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // HTML Video Element to display the camera feed
  final VideoElement _videoElement = VideoElement();
  // State flags and variables
  bool _isStreaming = false;
  bool _isDetecting = false; // Flag to prevent overlapping detection calls
  Timer? _detectionTimer;
  List<Map<String, dynamic>> _currentDetections = []; // Detections for the current frame
  final List<Map<String, dynamic>> _allDetectionsLog = []; // Log of all detections for the side panel
  int _videoWidth = 640; // Default width, updated once stream starts
  int _videoHeight = 480; // Default height, updated once stream starts
  String? _videoViewType; // Unique ID for registering the VideoElement view
  String? _errorMessage; // To display errors on screen

  // --- Initialization and Cleanup ---

  @override
  void initState() {
    super.initState();
    // Create a unique ID for the view factory based on the video element instance
    _videoViewType = 'video-view-${_videoElement.hashCode}';

    // IMPORTANT: Register the VideoElement with Flutter's view registry
    // This allows the HtmlElementView widget to render the _videoElement
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _videoViewType!,
          (int viewId) => _videoElement // Provide the VideoElement instance
        ..style.width = '100%' // Ensure video fills its container
        ..style.height = '100%'
        ..style.objectFit = 'cover', // Cover ensures video fills space, might crop
    );

    // Start the camera initialization process
    _initCamera();
  }

  @override
  void dispose() {
    print("Disposing CameraScreen...");
    _detectionTimer?.cancel(); // Stop the detection timer
    _stopCameraStream(); // Stop the camera stream and release resources
    _videoElement.remove(); // Remove the element from DOM (just in case)
    super.dispose();
  }

  // --- Camera Handling ---

  Future<void> _initCamera() async {
    setState(() { _errorMessage = null; }); // Clear previous errors
    print("Initializing camera...");
    try {
      // Request access to the user's camera
      // Using 'ideal' constraints can sometimes help select better cameras
      final stream = await window.navigator.mediaDevices!.getUserMedia({
        'video': {
          'facingMode': 'environment', // Prefer back camera if available
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        }
      });

      print("Camera stream obtained.");

      // Assign the stream to the video element
      _videoElement.srcObject = stream;
      _videoElement.autoplay = true; // Start playing automatically
      _videoElement.muted = true; // Mute audio to allow autoplay in most browsers

      // Listen for when the video metadata (like dimensions) is loaded
      _videoElement.onLoadedMetadata.listen((_) {
        if (!mounted) return; // Check if the widget is still active
        print("Video metadata loaded: ${_videoElement.videoWidth}x${_videoElement.videoHeight}");
        setState(() {
          // Update state with actual video dimensions
          _videoWidth = _videoElement.videoWidth ?? _videoWidth;
          _videoHeight = _videoElement.videoHeight ?? _videoHeight;
          _isStreaming = true; // Mark streaming as active
          _errorMessage = null; // Clear any previous error message
        });
        _startDetectionLoop(); // Start sending frames for detection
      });

      // Listen for potential errors with the video element itself
      _videoElement.onError.listen((event) {
        print("Video Element Error: $event");
        if (!mounted) return;
        setState(() {
          _isStreaming = false;
          _errorMessage = "Video stream error. Please check camera permissions.";
        });
        _stopCameraStream(); // Stop stream on error
      });

    } catch (e) {
      print("Camera initialization failed: $e");
      if (!mounted) return;
      setState(() {
        _isStreaming = false;
        if (e.toString().contains('NotFoundError') || e.toString().contains('DevicesNotFound')) {
          _errorMessage = "Camera not found. Please ensure a camera is connected and enabled.";
        } else if (e.toString().contains('NotAllowedError') || e.toString().contains('PermissionDeniedError')) {
          _errorMessage = "Camera permission denied. Please allow access in your browser settings.";
        } else {
          _errorMessage = "Failed to access camera: ${e.toString()}";
        }
      });
    }
  }

  void _stopCameraStream() {
    print("Stopping camera stream...");
    _detectionTimer?.cancel(); // Stop detection loop as well
    // Stop all tracks in the stream
    _videoElement.srcObject?.getTracks().forEach((track) {
      track.stop();
      print("Stopped track: ${track.label} (${track.kind})");
    });
    _videoElement.srcObject = null; // Release the stream object
    if (mounted) {
      setState(() {
        _isStreaming = false; // Update streaming status
        _isDetecting = false;
      });
    }
  }

  // --- Frame Capture and Processing ---

  Future<Uint8List?> _captureFrame() async {
    if (!_isStreaming || _videoWidth == 0 || _videoHeight == 0) {
      return null; // Cannot capture if not streaming or dimensions are unknown
    }

    // Create a temporary canvas to draw the current video frame onto
    final canvas = CanvasElement(width: _videoWidth, height: _videoHeight);
    final ctx = canvas.getContext('2d') as CanvasRenderingContext2D;

    // Draw the current frame from the video element onto the canvas
    ctx.drawImage(_videoElement, 0, 0);

    try {
      // Convert the canvas content to a Blob (binary large object) in JPEG format
      final blob = await canvas.toBlob('image/jpeg', 0.8); // 0.8 quality factor

      if (blob == null) return null;

      // Convert the Blob to a Uint8List (byte array)
      final reader = FileReader();
      reader.readAsArrayBuffer(blob);
      await reader.onLoad.first; // Wait for the reader to load the data
      return reader.result as Uint8List?;
    } catch (e) {
      print("Error capturing or converting frame: $e");
      return null;
    }
  }

  // --- Detection Loop ---

  void _startDetectionLoop() {
    _detectionTimer?.cancel(); // Cancel any existing timer

    if (!_isStreaming) {
      print("Cannot start detection loop: Not streaming.");
      return;
    }
    print("Starting detection loop...");

    // Set up a timer to periodically capture frames and send for detection
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      // Check conditions before proceeding
      if (!mounted || !_isStreaming || _isDetecting) {
        // If widget is disposed, not streaming, or already detecting, skip this cycle
        if (!_isStreaming && mounted) {
          print("Stopping detection timer because streaming stopped.");
          timer.cancel(); // Stop timer if streaming permanently stops
        }
        return;
      }

      setState(() { _isDetecting = true; }); // Mark as detecting

      final frameBytes = await _captureFrame();

      if (frameBytes != null) {
        await _sendFrameForDetection(frameBytes);
      } else {
        print("Skipping detection: Failed to capture frame.");
      }

      // Ensure state is updated even if detection wasn't attempted or failed
      if(mounted){
        setState(() { _isDetecting = false; }); // Mark detection as finished for this cycle
      }
    });
  }

  Future<void> _sendFrameForDetection(Uint8List frameBytes) async {
    try {
      // IMPORTANT: Replace with the IP address shown when you run your Python script
      final uri = Uri.parse('http://192.168.0.95:8000/detect'); // <-- YOUR PYTHON API URL HERE

      // Create a multipart request for sending the image file
      var request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'file', // The field name expected by the FastAPI backend
        frameBytes,
        filename: 'frame.jpg',
        contentType: MediaType('image', 'jpeg'), // Specify content type
      ));

      // Send the request and wait for the response
      final response = await request.send().timeout(const Duration(seconds: 5)); // Add timeout

      if (!mounted) return; // Check if widget is still mounted after async operation

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        if (data.containsKey('detections')) {
          final detections = List<Map<String, dynamic>>.from(data['detections']);
          final now = DateTime.now(); // Get timestamp when response is received

          setState(() {
            _currentDetections = detections; // Update detections for the current frame overlay
            // Add new detections to the log with timestamps
            _allDetectionsLog.addAll(detections.map((d) => {
              ...d,
              'timestamp': now,
            }));
            _errorMessage = null; // Clear error on success
          });

          // Optional: Limit the size of the log
          const maxLogSize = 200;
          if (_allDetectionsLog.length > maxLogSize) {
            _allDetectionsLog.removeRange(0, _allDetectionsLog.length - maxLogSize);
          }
        } else if (data.containsKey('error')) {
          print("API returned an error: ${data['error']}");
          setState(() { _errorMessage = "API Error: ${data['error']}"; });
        }

      } else {
        // Handle non-200 status codes (e.g., 404, 500)
        final errorBody = await response.stream.bytesToString();
        print("Detection API Error: Status ${response.statusCode}, Body: $errorBody");
        setState(() {
          _errorMessage = "API Error (${response.statusCode}). Check backend.";
          _currentDetections = []; // Clear boxes on error
        });
      }
    } on TimeoutException {
      print("Detection request timed out.");
      if (!mounted) return;
      setState(() { _errorMessage = "Detection request timed out."; });
    } catch (e) {
      // Handle network errors, parsing errors, etc.
      print("Error sending frame for detection: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = "Network error. Check API connection.";
        _currentDetections = []; // Clear boxes on error
      });
    }
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live CCTV Detection"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Row(
        children: [
          // --- Camera Feed and Bounding Boxes ---
          Expanded(
            flex: 3, // Give more space to the camera feed
            child: Container(
              color: Colors.black,
              child: LayoutBuilder( // Use LayoutBuilder to get actual container size
                builder: (context, constraints) {
                  // Calculate scaling factors based on container size and video size
                  final double scaleX = (_videoWidth > 0) ? constraints.maxWidth / _videoWidth : 0;
                  final double scaleY = (_videoHeight > 0) ? constraints.maxHeight / _videoHeight : 0;

                  return Stack(
                    fit: StackFit.expand, // Make Stack fill the LayoutBuilder
                    children: [
                      // Display the video stream using HtmlElementView
                      if (_isStreaming && _videoViewType != null)
                        SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: HtmlElementView(viewType: _videoViewType!),
                        ),

                      // Show loading indicator or error message
                      if (!_isStreaming)
                        Center(
                          child: _errorMessage != null
                              ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          )
                              : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white,),
                              SizedBox(height: 10),
                              Text("Initializing Camera...", style: TextStyle(color: Colors.white70))
                            ],
                          ),
                        ),

                      // Overlay bounding boxes on top of the video
                      // Ensure scaling factors are valid before drawing
                      if (scaleX > 0 && scaleY > 0)
                        ..._currentDetections.map((detection) =>
                            _buildBoundingBox(detection, scaleX, scaleY)
                        ).toList(),

                      // Display detection error messages overlayed on the video area
                      if (_errorMessage != null && _isStreaming)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: Colors.black.withOpacity(0.6),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.yellow, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  );
                },
              ),
            ),
          ),

          // --- Detection Log Panel ---
          Expanded(
            flex: 1, // Smaller portion for the log
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
                color: Colors.grey[50], // Light background for the log
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Detection Log",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800]),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    // Use ListView.builder for efficient scrolling
                    child: ListView.builder(
                      itemCount: _allDetectionsLog.length,
                      reverse: true, // Show newest detections at the top of the visible list
                      itemBuilder: (context, index) {
                        // Access detections in reverse order for display
                        final detection = _allDetectionsLog[_allDetectionsLog.length - 1 - index];
                        final label = detection['label'] ?? 'N/A';
                        final confidence = ((detection['confidence'] ?? 0.0) * 100).toStringAsFixed(1);
                        final timestamp = detection['timestamp'] as DateTime?;
                        final timeString = timestamp != null
                            ? "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}"
                            : "--:--:--";

                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
                          title: Text(
                            "$label ($confidence%)",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            timeString,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          // Optional: Add icons based on label
                          // leading: Icon(_getIconForLabel(label)),
                        );
                      },
                    ),
                  ),
                  // Optional: Add a button to clear the log
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 8.0),
                  //   child: Center(
                  //     child: TextButton(
                  //       onPressed: () => setState(() => _allDetectionsLog.clear()),
                  //       child: const Text("Clear Log"),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build a single bounding box overlay
  Widget _buildBoundingBox(Map<String, dynamic> detection, double scaleX, double scaleY) {
    // Safely extract box coordinates, providing defaults if null
    final box = List<double>.from(detection['box']?.map((e) => (e as num).toDouble()) ?? [0.0, 0.0, 0.0, 0.0]);
    final label = detection['label'] ?? 'Unknown';
    final confidence = (detection['confidence'] as num?)?.toDouble() ?? 0.0;

    // Basic validation for coordinates and scale
    if (scaleX <= 0 || scaleY <= 0 || box[2] <= box[0] || box[3] <= box[1]) {
      return const SizedBox.shrink(); // Return empty widget if data is invalid
    }

    // Calculate position and size based on scaling factors
    final double left = box[0] * scaleX;
    final double top = box[1] * scaleY;
    final double width = (box[2] - box[0]) * scaleX;
    final double height = (box[3] - box[1]) * scaleY;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent, width: 2), // Slightly different red
        ),
        child: Align( // Align text to top-left inside the box
          alignment: Alignment.topLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            color: Colors.black.withOpacity(0.6), // Semi-transparent background
            child: Text(
              "$label ${(confidence * 100).toStringAsFixed(0)}%", // Confidence as integer %
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11, // Slightly smaller font
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis, // Prevent text overflow
            ),
          ),
        ),
      ),
    );
  }

// Example helper for icons (optional)
// IconData _getIconForLabel(String label) {
//   switch (label.toLowerCase()) {
//     case 'person': return Icons.person;
//     case 'car': return Icons.directions_car;
//     // Add more cases as needed
//     default: return Icons.label_important;
//   }
// }
}
