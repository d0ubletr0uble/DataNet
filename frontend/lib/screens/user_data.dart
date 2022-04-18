import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

class UserData extends StatelessWidget {
  const UserData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DataNet'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0,15,0,0),
        child: JsonViewer(jsonDecode(args)),
      ),
    );
  }
}
