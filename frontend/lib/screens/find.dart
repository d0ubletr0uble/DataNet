import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/screens/edit.dart';
import 'package:myapp/screens/face_list_find.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'loading.dart';

class Find extends StatelessWidget {
  const Find({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as FaceSearchRow;

    final user = http
        .post(
          Uri.parse('${Constants.api}/users/find'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: jsonEncode({'embedding': args.embedding}),
        )
        .then((res) => User.fromJson(res));

    return Scaffold(
      appBar: AppBar(
        title: const Text('DataNet'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<User>(
          future: user,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingScreen();
            } else {
              return Image.network(snapshot.data!.photo);
            }
          }),
    );
  }
}
