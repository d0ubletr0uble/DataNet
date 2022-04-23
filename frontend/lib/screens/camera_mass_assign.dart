import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:json_editor/json_editor.dart';
import 'package:myapp/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:myapp/screens/loading.dart';


class CameraAssign extends StatefulWidget {
  const CameraAssign({Key? key}) : super(key: key);

  @override
  State<CameraAssign> createState() => _CameraAssignState();
}

class _CameraAssignState extends State<CameraAssign> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as JsonElement;
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
                        await _pickImage(ImageSource.camera, args);
                      },
                      child: const SizedBox.expand(
                        child: FittedBox(
                          child: Icon(Icons.camera),
                        ),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 10),
                    child: OutlinedButton(
                      onPressed: () async {
                        await _pickImage(ImageSource.gallery, args);
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

  _pickImage(ImageSource source, JsonElement data) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoadingScreen()),
      );

      final resp = await pickedFile
          .readAsBytes()
          .then((bytes) => base64Encode(bytes))
          .then(
            (image) => http.post(
              Uri.parse('${Constants.api}/users/batch-edit'),
              body: {'image': image, 'data': jsonEncode(data.toObject())},
            ),
          )
          .then((res) => jsonDecode(res.body));

      Navigator.of(context).pop();

      var snackBar =
          SnackBar(content: Text('users updated: ${resp['updated']}'));
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar)
          .closed
          .then((_) => Navigator.popUntil(context, ModalRoute.withName('/')));
    }
  }
}
