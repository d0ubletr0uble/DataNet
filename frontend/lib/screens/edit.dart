import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:myapp/screens/loading.dart';

import '../constants.dart';
import 'input.dart';

class User extends StatelessWidget {
  final String id;
  final String photo;

  final String data;

  const User(
      {Key? key, required this.id, required this.photo, required this.data})
      : super(key: key);

  factory User.fromJson(dynamic json) {
    final id = json['_id'];
    final photo = '${Constants.s3}/users/$id.jpg';
    json.remove('_id');

    return User(id: id, photo: photo, data: jsonEncode(json));
  }

  void save(data) {
    print('saving $id - $data');

    http.put(
      Uri.parse('${Constants.api}/users/$id'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(data.toObject()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Flexible(
          child: Image.network(photo, fit: BoxFit.fitHeight),
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
                'Edit User Data',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final data = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Input(
                      example: this.data,
                      buttonText: 'Save',
                    ),
                  ),
                );

                save(data);
              },
            ),
          ),
          flex: 2,
        ),
      ]),
    );
  }
}

class Edit extends StatelessWidget {
  final Future<String> users;

  const Edit({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingScreen();
          } else {
            final users = jsonDecode(snapshot.data!)['users']
                .map<User>((u) => User.fromJson(u))
                .toList();

            Size size = MediaQuery.of(context).size;

            return Scaffold(
              appBar: AppBar(
                title: const Text('DataNet'),
                backgroundColor: Colors.blue,
              ),
              body: ListView(
                itemExtent: size.height / 4,
                children: ListTile.divideTiles(
                  context: context,
                  tiles: users,
                ).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
