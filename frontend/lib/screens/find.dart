import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../constants.dart';

class UserCard extends StatelessWidget {
  final String id;
  final String photo;
  final String similarity;

  final String data;

  const UserCard({
    Key? key,
    required this.id,
    required this.photo,
    required this.similarity,
    required this.data,
  }) : super(key: key);

  factory UserCard.fromJson(dynamic json) {
    final id = json['_id'];

    return UserCard(
      id: id,
      photo: '${Constants.s3}/users/$id.jpg',
      similarity: json['similarity'],
      data: jsonEncode(json['data']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0x56aec4eb)),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(60),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/user-data',
                  arguments: data,
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(photo)),
              ),
            ),
            const Text('Similarity:'),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(similarity),
            ),
          ],
        ),
      ),
    );
  }
}

class Find extends StatelessWidget {
  Find({Key? key}) : super(key: key);
  final buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List<UserCard>;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DataNet'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: CarouselSlider(
              options: CarouselOptions(height: size.height * 0.7),
              carouselController: buttonCarouselController,
              items: args,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () => buttonCarouselController.previousPage(),
                icon: const Icon(Icons.arrow_left),
              ),
              IconButton(
                onPressed: () => buttonCarouselController.nextPage(),
                icon: const Icon(Icons.arrow_right),
              ),
            ],
          )
        ],
      ),
    );
  }
}
