import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math' as math;

class DetectorPosturaScreen extends StatefulWidget {
  @override
  _DetectorPosturaScreenState createState() => _DetectorPosturaScreenState();
}

class _DetectorPosturaScreenState extends State<DetectorPosturaScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _postureStatus = '';

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _detectPosture() async {
    if (_imageFile != null) {
      final inputImage = InputImage.fromFilePath(_imageFile!.path);
      final poseDetector = GoogleMlKit.vision.poseDetector();

      try {
        print("Iniciando detecção de postura...");
        final List<Pose> poses = await poseDetector.processImage(inputImage);

        if (poses.isNotEmpty) {
          final pose = poses[0];
          final shoulderLeft = pose.landmarks[PoseLandmarkType.leftShoulder];
          final shoulderRight = pose.landmarks[PoseLandmarkType.rightShoulder];
          final hipLeft = pose.landmarks[PoseLandmarkType.leftHip];
          final hipRight = pose.landmarks[PoseLandmarkType.rightHip];

          if (shoulderLeft != null &&
              shoulderRight != null &&
              hipLeft != null &&
              hipRight != null) {
            final angle = _calculateAngle(
              Offset(shoulderLeft.x, shoulderLeft.y),
              Offset(shoulderRight.x, shoulderRight.y),
              Offset(hipLeft.x, hipLeft.y),
              Offset(hipRight.x, hipRight.y),
            );

            setState(() {
              _postureStatus =
                  angle < 60
                      ? 'Postura correta (coluna reta)'
                      : 'Postura incorreta (coluna curvada)';
            });
          } else {
            setState(() {
              _postureStatus =
                  'Não foi possível detectar todas as articulações.';
            });
          }
        } else {
          setState(() {
            _postureStatus = 'Não foi possível detectar a postura.';
          });
        }

        print("Postura detectada: $_postureStatus");
      } catch (e) {
        print("Erro na detecção de postura: $e");
        setState(() {
          _postureStatus = 'Erro na detecção de postura.';
        });
      } finally {
        poseDetector.close();
      }
    }
  }

  double _calculateAngle(Offset p1, Offset p2, Offset p3, Offset p4) {
    final dx1 = p2.dx - p1.dx;
    final dy1 = p2.dy - p1.dy;
    final dx2 = p4.dx - p3.dx;
    final dy2 = p4.dy - p3.dy;
    final angle1 = math.atan2(dy1, dx1);
    final angle2 = math.atan2(dy2, dx2);
    return (angle1 - angle2).abs() * 180 / math.pi;
  }

  void _clearDetection() {
    setState(() {
      _imageFile = null;
      _postureStatus = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0047AB),
        title: Text(
          'Detector de Postura',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF0047AB), width: 5),
            ),
            child:
                _imageFile == null
                    ? Center(
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Color(0xFF0047AB),
                      ),
                    )
                    : Image.file(_imageFile!, fit: BoxFit.contain),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF0047AB),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF0047AB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _detectPosture,
                  child: Text('Detectar Postura'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF0047AB),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF0047AB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _clearDetection,
                  child: Text('Limpar Detecção'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImageFromGallery,
                      child: Text('Galeria'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _takePicture,
                      child: Text('Câmera'),
                    ),
                  ],
                ),
                if (_postureStatus.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _postureStatus,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
