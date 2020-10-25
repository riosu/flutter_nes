import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nes/emulator/emulator.dart';
import 'package:flutter_nes/emulator/rom.dart';
import 'package:flutter_nes/widgets/emulator.dart';
import 'package:flutter_nes/widgets/emulator_status.dart';

class EmulatorPageWidget extends StatefulWidget {
  @override
  _EmulatorPageState createState() => _EmulatorPageState();
}

class _EmulatorPageState extends State<EmulatorPageWidget> {
  Emulator emulator;

  Widget build(BuildContext context) {
    if (emulator == null) {
      Uint8List romBytes = ModalRoute.of(context).settings.arguments;
      emulator = new Emulator(romBytes);
    }

    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: EmulatorMainWidget(emulator: emulator),
          ),
          Container(
            width: 300.0,
            child: EmulatorStatusWidget(emulator: emulator),
          )
        ]
      ),
    );
  }
}
