import 'package:flutter/material.dart';
import 'package:json_editor/json_editor.dart';

class Input extends StatefulWidget {
  final String example;
  final String buttonText;
  const Input({Key? key, required this.example, required this.buttonText}) : super(key: key);


  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  bool _darkMode = false;
  JsonElement? _elementResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkMode
          ? ThemeData.dark().scaffoldBackgroundColor
          : ThemeData.light().scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('DataNet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Switch(
                  value: _darkMode,
                  onChanged: (b) => setState(() => _darkMode = b),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: _darkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pop(_elementResult),
                    child: Text(widget.buttonText))
              ],
            ),
            Expanded(
              child: Theme(
                data: _darkMode ? ThemeData.dark() : ThemeData.light(),
                child: JsonEditor.string(
                  jsonString: widget.example,
                  onValueChanged: (value) => _elementResult = value,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
