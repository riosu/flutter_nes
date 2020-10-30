import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nes/emulator/emulator_isolate.dart';

class EmulatorPageWidget extends StatefulWidget {
  @override
  _EmulatorPageState createState() => _EmulatorPageState();
}

class _EmulatorPageState extends State<EmulatorPageWidget> {
  ValueNotifier<ui.Image> notifier = ValueNotifier(null); 

  ReceivePort emulatorReceivePort;
  SendPort emulatorSendPort;

  @override
  void initState() {
    super.initState();

    emulatorReceivePort = ReceivePort();
    Isolate.spawn(emulatorIsolateMain, emulatorReceivePort.sendPort);
 
    emulatorReceivePort.listen((m) {
      var message = m as EmulatorMessage;
      switch(message.type) {
        case EmulatorMessageType.INITIALIZE:
          emulatorSendPort = message.data as SendPort;

          // エミュレータ初期化        
          Uint8List romBytes = ModalRoute.of(context).settings.arguments;
          emulatorSendPort.send(
            EmulatorMessage(
              EmulatorMessageType.START,
              romBytes
            )
          );
          break;

        case EmulatorMessageType.UPDATE_FRAME:
          _convertFrameToImage(message.data).then((ui.Image image) {
            notifier.value = image;
          });
          break;

        default:
          break;
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black38,
              child: CustomPaint(
                painter: _EmulatorDrawPainter(notifier),
              )
            )
          ),
          Container(
            width: 300.0,
            child: Container(
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
          )
        ]
      ),
    );
  }
}

class _EmulatorDrawPainter extends CustomPainter {
  ValueNotifier<ui.Image> notifier;
  Paint paintObject;

  int framePerSec = 0;
  int lastDrawTime = 0;
  int frameDrawCount = 0;

  _EmulatorDrawPainter(this.notifier): super(repaint: notifier) {
    paintObject = Paint();
  }

  @override
  void paint(Canvas canvas, Size size) {
    frameDrawCount++;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastDrawTime > 1000) {
      lastDrawTime = currentTime;
      framePerSec = frameDrawCount;
      frameDrawCount = 0;
    }

    canvas.save();
    if (notifier.value != null) {
      var scale = (size.width / 256 < size.height / 240) ? size.width / 256 : size.height / 240;
      canvas.scale(scale);      
      canvas.drawImage(notifier.value, Offset.zero, paintObject);
    }

    TextSpan span = new TextSpan(style: new TextStyle(color: Colors.white, fontSize: 8.0), text: "fps: $framePerSec");
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(5.0, 5.0));

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
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