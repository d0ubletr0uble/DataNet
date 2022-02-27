import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'screens/camera.dart';

void main() {
  runApp(MaterialApp(
    title: 'DataNet',
    routes: {
      '/': (context) => const Home(),
      '/camera': (context) => const Camera(),
    },
  ));
}
