import 'dart:io';

import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'screens/camera.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(MaterialApp(
    theme: ThemeData(
      brightness: Brightness.dark
    ),
    title: 'DataNet',
    routes: {
      '/': (context) => const Home(),
      '/camera': (context) => const Camera(),
    },
  ));
}
