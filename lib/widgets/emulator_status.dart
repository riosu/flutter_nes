import 'package:flutter/material.dart';
import 'package:flutter_nes/emulator/emulator.dart';

class EmulatorStatusWidget extends StatefulWidget {
  final Emulator emulator;

  EmulatorStatusWidget({ this.emulator });

  @override
  _EmulatorStatusState createState() => _EmulatorStatusState();
}

class _EmulatorStatusState extends State<EmulatorStatusWidget> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black12,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("Emulator Status Widget")
            ]
          )
        ),
      ),
    );
  }
}