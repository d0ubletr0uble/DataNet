import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/constants.dart';
import 'package:myapp/screens/face_list.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('DataNet'), backgroundColor: Colors.blue),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: AspectRatio(
            aspectRatio: 1.62,
            child: FractionallySizedBox(
              heightFactor: 0.8,
              widthFactor: 0.9,
              child: GridView.count(
                crossAxisCount: kIsWeb ? 1 : 2,
                childAspectRatio: kIsWeb ? 4 : 0.8,
                crossAxisSpacing: 50,
                shrinkWrap: true,
                primary: false,
                padding: const EdgeInsets.all(5),
                children: [
                  if (!kIsWeb)
                    OutlinedButton(
                      onPressed: () async {
                        await _pickImage(ImageSource.camera);
                      },
                      child: const SizedBox.expand(
                        child: FittedBox(
                          child: Icon(Icons.camera),
                        ),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 10),
                    child: OutlinedButton(
                      onPressed: () async {
                        await _pickImage(ImageSource.gallery);
                      },
                      child: const SizedBox.expand(
                        child: FittedBox(
                          child: Icon(Icons.image),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      final bytes = base64Encode(await pickedFile.readAsBytes());
      final res = await http.post(
        Uri.parse('${Constants.api}/image/upload'),
        body: {'image': bytes},
      );

      final faceList = FaceList.fromJson(jsonDecode(res.body));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FaceListInput(faceList: faceList)),
      );
    }
  }
}

class FaceList {
  final List<Face> faces;

  FaceList({required this.faces});

  factory FaceList.fromJson(Map<String, dynamic> json) {
    return FaceList(
        faces: List<Face>.from(json['faces'].map((f) => Face.fromJson(f))));
  }
}

class Face {
  final String face;
  final List<double> embedding;

  Face({required this.face, required this.embedding});

  factory Face.fromJson(Map<String, dynamic> json) {
    return Face(
        face: json['face'], embedding: json['embedding'].cast<double>());
  }
}
