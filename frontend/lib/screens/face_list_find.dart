import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_editor/json_editor.dart';
import 'package:myapp/screens/camera.dart';
import 'package:myapp/screens/input.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screens/loading.dart';

import '../constants.dart';
import 'face_list.dart';

class FaceListFind extends StatelessWidget {
  final Future<FaceList> faceList;
  final Map<String, FaceUpload> _results = {};

  FaceListFind({Key? key, required this.faceList}) : super(key: key);

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
                tiles: snapshot.data!.faces.map((f) => FaceSearchRow(
                      size: size,
                      imageString: f.face,
                      embedding: f.embedding,
                    )),
              ).toList(),
            ),
          );
        } else {
          return const LoadingScreen();
        }
      },
    );
  }
}

class FaceSearchRow extends StatelessWidget {
  final String imageString;
  final List<double> embedding;
  final Size size;

  const FaceSearchRow({
    Key? key,
    required this.size,
    required this.imageString,
    required this.embedding,
  }) : super(key: key);

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
                  'Search',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/find',
                  arguments: this,
                ),
              ),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }
}
