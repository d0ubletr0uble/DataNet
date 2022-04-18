import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SpinKitSpinningLines(
        color: Colors.blue,
        lineWidth: w / 60,
        size: w / 4,
      ),
    );
  }
}
