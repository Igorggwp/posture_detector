import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'body_detection.dart';
import 'models/pose.dart';
import 'png_image.dart';

class DetectorPosturaScreen extends StatefulWidget {
  @override
  _DetectorPosturaScreenState createState() => _DetectorPosturaScreenState();
}

class _DetectorPosturaScreenState extends State<DetectorPosturaScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  Pose? _detectedPose;

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
      final imageBytes = await _imageFile!.readAsBytes();
      final image = await decodeImageFromList(imageBytes);

      final PngImage? pngImage = await image.toPngImage();
      if (pngImage != null) {
        try {
          print("Iniciando detecção de postura...");
          final Pose? pose = await BodyDetection.detectPose(image: pngImage);
          setState(() {
            _detectedPose = pose;
          });
          print("Postura detectada: $pose");
        } catch (e) {
          print("Erro na detecção de postura: $e");
        }
      }
    }
  }

  void _clearDetection() {
    setState(() {
      _imageFile = null;
      _detectedPose = null;
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
            height: 350,
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
                    : Image.file(_imageFile!, fit: BoxFit.cover),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
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
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF0047AB),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFF0047AB)),
                        minimumSize: Size(100, 100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _pickImageFromGallery,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_back_outlined,
                            size: 40,
                            color: Color(0xFF0047AB),
                          ),
                          SizedBox(height: 5),
                          Text('Galeria'),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF0047AB),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFF0047AB)),
                        minimumSize: Size(100, 100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _takePicture,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Color(0xFF0047AB),
                          ),
                          SizedBox(height: 5),
                          Text('Câmera'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_detectedPose != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Postura detectada:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Pose: $_detectedPose'),
                      ],
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
