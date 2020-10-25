import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nes/emulator/emulator.dart';

class EmulatorMainWidget extends StatefulWidget {
  final Emulator emulator;

  EmulatorMainWidget({ this.emulator });

  @override
  _EmulatorMainState createState() => _EmulatorMainState();
}

class _EmulatorMainState extends State<EmulatorMainWidget> {
  ui.Image frameImage;

  int framePerSecTmp = 0;
  int framePerSec = 0;

  Widget build(BuildContext context) {
    if (!widget.emulator.isRunning) {
      widget.emulator.start();
    }

    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: Stack(
          children: <Widget>[
            Center(
              child: (frameImage == null) ? 
                null : 
                RawImage(
                  image: frameImage,
                  fit: BoxFit.fill,
                  scale: 0.5,
                )
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "fps: $framePerSec",
                  style: TextStyle(
                    color: Colors.white
                  )
                )
              )
            )
          ]
        )
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    widget.emulator.onFrameChanged.listen((frame) {
      _convertFrameToImage(frame).then((image) {
        setState(() {
          frameImage = image;
          framePerSecTmp++;
        });
      });
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      framePerSec = framePerSecTmp;
      framePerSecTmp = 0;
    });
  }
}

Future<ui.Image> _convertFrameToImage(Uint8List pixels) {
  final c = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    256,
    240,
    ui.PixelFormat.rgba8888,
    c.complete,
  );
  return c.future;
}