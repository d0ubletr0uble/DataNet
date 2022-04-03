import 'package:flutter/material.dart';

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
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const SizedBox.expand(
                    child: FittedBox(
                      child: Icon(Icons.search),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const SizedBox.expand(
                    child: FittedBox(
                      child: Icon(Icons.portrait_outlined),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const SizedBox.expand(
                    child: FittedBox(
                      child: Icon(Icons.assignment_rounded),
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
