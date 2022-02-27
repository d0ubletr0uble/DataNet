import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';

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
                      onPressed: () {
                        _pickImage(ImageSource.camera);
                      },
                      child: const SizedBox.expand(
                        child: FittedBox(
                          child: Icon(Icons.camera),
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _pickImage(ImageSource.gallery);
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

  /// Get from gallery
  _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      // var stream = ByteStream(pickedFile.openRead());
      var request = MultipartRequest('POST', Uri.parse('http://127.0.0.1:4444'));
      var file = MultipartFile('file', pickedFile.openRead(), await pickedFile.length());
      request.files.add(file);
      var res = await request.send();
      print(res);
      // setState(() {
      //   _imageFile = pickedFile;
      // });
    }
  }
}
