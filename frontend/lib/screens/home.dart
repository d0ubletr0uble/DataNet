import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_editor/json_editor.dart';
import 'package:myapp/screens/edit.dart';
import '../constants.dart';
import 'input.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    bool horizontal = w > h;

    return Scaffold(
      appBar:
          AppBar(title: const Text('DataNet'), backgroundColor: Colors.blue),
      body: Center(
        child: AspectRatio(
          aspectRatio: horizontal ? 1.62 : 1 / 1.62,
          child: FractionallySizedBox(
            heightFactor: 0.8,
            widthFactor: 0.9,
            child: GridView.count(
              crossAxisCount: horizontal ? 4 : 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.all(5),
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/camera'),
                  child: const SizedBox.expand(
                    child: FittedBox(
                      child: Icon(Icons.person_add),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const SizedBox.expand(
                    child: FittedBox(
                      child: Icon(Icons.person_search),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    JsonElement search = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const Input(example: '{}', buttonText: 'Search')),
                    ) ?? JsonElement(value: '{}');

                    final users = http.post(
                      Uri.parse('${Constants.api}/users/search'),
                      headers: {
                        HttpHeaders.contentTypeHeader: 'application/json'
                      },
                      body: search.toString(),
                    ).then((res) => res.body);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Edit(users: users)),
                    );
                  },
                  child: const SizedBox.expand(
                    child: FittedBox(
                      child: Icon(Icons.find_in_page_rounded),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const SizedBox.expand(
                    child: FittedBox(
                      child: Icon(Icons.edit),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
