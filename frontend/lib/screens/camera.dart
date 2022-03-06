import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as parser;

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  XFile? _imageFile;

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
              child: Container(
                color: Colors.grey,
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 50,
                  shrinkWrap: true,
                  primary: false,
                  padding: const EdgeInsets.all(5),
                  children: [
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
                    OutlinedButton(
                      onPressed: () async {
                        await _pickImage(ImageSource.gallery);
                      },
                      child: const SizedBox.expand(
                        child: FittedBox(
                          child: Icon(Icons.image),
                        ),
                      ),
                    ),
                  ],
                ),
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
      var bytes = await pickedFile.readAsBytes();
      var res = await http.post(
          Uri.parse('http://192.168.6.104:8080/image/upload'),
          body: {'image': base64Encode(bytes)});

      print(res);
    }
  }
}
