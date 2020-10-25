import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';

class TopPageWidget extends StatefulWidget {
  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPageWidget> {
  void _openWithFile(widgetPath) async {
    var result = await showOpenPanel(
      initialDirectory: "./roms",
      allowsMultipleSelection: false,
      allowedFileTypes: [FileTypeFilterGroup(fileExtensions: ["nes"])]
    );
    if (!result.canceled) {
      var rom = File(result.paths[0]);
      var bytes = rom.readAsBytesSync();
      Navigator.of(context).pushNamed(widgetPath, arguments: bytes);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ButtonTheme(
              minWidth: double.infinity,
              child: MaterialButton(
                child: Text("Start Emulator"),
                onPressed: () => _openWithFile("/emulator"),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ButtonTheme(
              minWidth: double.infinity,
              child: MaterialButton(
                child: Text("View Stripe"),
                onPressed: () => _openWithFile("/stripe"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}