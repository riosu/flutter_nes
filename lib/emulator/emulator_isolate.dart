import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_nes/emulator/emulator.dart';

enum EmulatorMessageType {
  INITIALIZE,
  START,
  UPDATE_FRAME,
}

class EmulatorMessage {
  EmulatorMessageType type;
  dynamic data;

  EmulatorMessage(this.type, this.data);
}

void emulatorIsolateMain(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  mainSendPort.send(
    EmulatorMessage(
      EmulatorMessageType.INITIALIZE, 
      receivePort.sendPort
    )
  );

  Emulator emulator;
  await for (var m in receivePort) {
    var message = m as EmulatorMessage;
    switch(message.type) {
      case EmulatorMessageType.START:
        emulator = new Emulator(message.data as Uint8List);
        emulator.onFrameChanged.listen((frame) {
          // フレーム更新を通知
          mainSendPort.send(
            EmulatorMessage(
              EmulatorMessageType.UPDATE_FRAME,
              frame
            )
          );         
        });
        emulator.start();
        break;

      default:
        break;
    }
  }
}
