import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class CameraScreen extends StatefulWidget {
  final String exercise;

  const CameraScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  String? _videoPath;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError("No cameras available!");
        return;
      }

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      _showError("Error initializing camera: $e");
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      await _controller!.prepareForVideoRecording();
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);

      _recordingTimer = Timer(const Duration(seconds: 5), () {
        if (_isRecording) {
          _stopRecording();
        }
      });
    } catch (e) {
      _showError("Error starting video recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();

      final XFile xFile = await _controller!.stopVideoRecording();
      final File file = File(xFile.path);

      setState(() {
        _isRecording = false;
        _videoPath = file.path;
      });

      _analyzeVideo(file);
    } catch (e) {
      _showError("Error stopping video recording: $e");
    }
  }

  Future<void> _analyzeVideo(File file) async {
    try {
      final uri = Uri.parse('http://172.20.10.5:8002/analyze');
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['exercise'] = widget.exercise
            ..files.add(await http.MultipartFile.fromPath('video', file.path));

      final response = await request.send();
      final result = await response.stream.bytesToString();

      _showResultDialog(result);
    } catch (e) {
      _showError("Error analyzing video: $e");
    }
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Analysis Result'),
            content: Text(result),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise)),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (_controller == null || !_controller!.value.isInitialized) {
            return const Center(child: Text('Camera not initialized'));
          } else {
            return Stack(
              children: [
                CameraPreview(_controller!),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FloatingActionButton(
                      onPressed: _toggleRecording,
                      backgroundColor: _isRecording ? Colors.red : Colors.green,
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.circle,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
