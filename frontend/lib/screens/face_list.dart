import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_editor/json_editor.dart';
import 'package:myapp/screens/camera.dart';
import 'package:myapp/screens/input.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants.dart';

class FaceUpload {
  final String face;
  final List<double> embedding;
  final JsonElement data;

  FaceUpload({required this.face, required this.embedding, required this.data});
}

class FaceListInput extends StatelessWidget {
  final Future<FaceList> faceList;
  final Map<String, FaceUpload> _results = {};

  FaceListInput({Key? key, required this.faceList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder<FaceList>(
      future: faceList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) {
            Future.delayed(
                const Duration(seconds: 2), () => Navigator.of(context).pop());
            return const Scaffold(
                body: AlertDialog(title: Text('no faces were found')));
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('DataNet'),
              backgroundColor: Colors.blue,
            ),
            body: ListView(
              itemExtent: size.height / 4,
              children: ListTile.divideTiles(
                context: context,
                tiles: snapshot.data!.faces.map((f) => FaceRow(
                      size: size,
                      imageString: f.face,
                      embedding: f.embedding,
                      onSave: (data) {
                        if (data != null) {
                          _results[f.face] = FaceUpload(
                            face: f.face,
                            embedding: f.embedding,
                            data: data,
                          );
                        }
                      },
                    )),
              ).toList(),
            ),
            floatingActionButton: FloatingActionButton.extended(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                final b = jsonEncode({
                  'faces': _results.entries
                      .map((e) => {
                            'face': e.key,
                            'embedding': e.value.embedding,
                            'data': e.value.data.toObject(),
                          })
                      .toList()
                });
                final res = await http.post(
                  Uri.parse('${Constants.api}/users'),
                  headers: {HttpHeaders.contentTypeHeader: 'application/json'},
                  body: b,
                );
                if (res.statusCode == 201) {
                  const snackBar = SnackBar(content: Text('users created'));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(snackBar)
                      .closed
                      .then((_) => Navigator.popUntil(
                          context, ModalRoute.withName('/')));
                } else {
                  var snackBar = SnackBar(content: Text(res.body));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          );
        } else {
          var w = MediaQuery.of(context).size.width;
          return Scaffold(body: SpinKitSpinningLines(color: Colors.blue, lineWidth: w/60, size: w/4));
        }
      },
    );
  }
}

class FaceRow extends StatelessWidget {
  final String imageString;
  final List<double> embedding;
  final Size size;
  final void Function(JsonElement? data) onSave;

  const FaceRow(
      {Key? key,
      required this.size,
      required this.imageString,
      required this.embedding,
      required this.onSave})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Flexible(
            child:
                Image.memory(base64Decode(imageString), fit: BoxFit.fitHeight),
            flex: 1,
            fit: FlexFit.tight,
          ),
          Flexible(
            child: Center(
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff337ab7),
                    textStyle: TextStyle(fontSize: size.width / 22),
                    padding: EdgeInsets.all(size.height / 25)),
                child: const Text(
                  'Enter Data',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final data = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Input()),
                  );
                  onSave(data);
                },
              ),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }
}
