import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nes/isolates/emulator.dart';
import 'package:flutter_nes/isolates/messages/emulator_messages.dart';

class EmulatorPageWidget extends StatefulWidget {
  @override
  _EmulatorPageState createState() => _EmulatorPageState();
}

class _EmulatorPageState extends State<EmulatorPageWidget> {
  _EmulatorController controller;


  @override
  void initState() {
    super.initState();

    controller = _EmulatorController();
    Future.delayed(Duration.zero, () {
      // Uint8List romBytes = ModalRoute.of(context).settings.arguments;
      // controller.initialize(romBytes);
      rootBundle.loadString("./roms/nestest.log").then((log) => {
        rootBundle.load("./roms/nestest.nes").then((rom) => {
          controller.initialize(rom.buffer.asUint8List(), log)
        })
      });
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
                painter: _EmulatorDrawPainter(controller),
              )
            )
          ),
          // Container(
          //   width: 300.0,
          //   child: Container(
          //     color: Colors.black12,
          //     width: double.infinity,
          //     child: Padding(
          //       padding: EdgeInsets.all(10.0),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         children: <Widget>[
          //           Text("Emulator Status Widget")
          //         ]
          //       )
          //     ),
          //   ),
          // )
        ]
      ),
    );
  }
}


class _EmulatorController extends ChangeNotifier {
  Uint8List romBytes;
  String debugCPULog;

  ReceivePort emulatorReceivePort;
  SendPort emulatorSendPort;

  ui.Image currentFrame;

  _EmulatorController();

  void initialize(Uint8List romBytes, [String debugCPULog]) {
    this.romBytes = romBytes;
    this.debugCPULog = debugCPULog;
    _initializeEmulatorIsolate();
  }

  void _initializeEmulatorIsolate() {
    emulatorReceivePort = ReceivePort();
    Isolate.spawn(emulatorIsolateMain, emulatorReceivePort.sendPort);

    emulatorReceivePort.listen((data) {
      var message = data as EmulatorMessageByChild;
      switch(message.type) {
        case EmulatorMessageByChildType.INITIALIZE:
          _onRecvInitialize(message.data);
          break;

        case EmulatorMessageByChildType.UPDATE_FRAME:
          _onRecvUpdateFrame(message.data);
          break;
      }      
    });
  }

  void _onRecvInitialize(SendPort emulatorSendPort) {
    this.emulatorSendPort = emulatorSendPort;

    // デバッグログがある場合はIsolateにわたす
    if (debugCPULog != null) {
      emulatorSendPort.send(
        EmulatorMessageByParent(
          EmulatorMessageByParentType.SET_DEBUG_CPU_LOG,
          debugCPULog
        )
      );
    }

    // エミュレータ開始
    emulatorSendPort.send(
      EmulatorMessageByParent(
        EmulatorMessageByParentType.START,
        romBytes
      )
    );
  }

  void _onRecvUpdateFrame(Uint8List framePixels) {
    _convertFrameToImage(framePixels).then((ui.Image image) {
      currentFrame = image;
      notifyListeners();
    });
  }
}

class _EmulatorDrawPainter extends CustomPainter {
  _EmulatorController controller;
  Paint paintObject;

  int framePerSec = 0;
  int lastDrawTime = 0;
  int frameDrawCount = 0;

  _EmulatorDrawPainter(this.controller): super(repaint: controller) {
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
    var scale = (size.width / 256 < size.height / 240) ? size.width / 256 : size.height / 240;
    canvas.scale(scale);      

    if (controller.currentFrame != null) {
      canvas.drawImage(controller.currentFrame, Offset.zero, paintObject);
    }

    // Draw fps
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