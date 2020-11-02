import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_nes/emulator/emulator.dart';
import 'package:flutter_nes/isolates/messages/emulator_messages.dart';


void emulatorIsolateMain(SendPort parentSendPort) async {
  final emulatorIsolate = EmulatorIsolate(parentSendPort, ReceivePort());
  emulatorIsolate.main();
}

class EmulatorIsolate {
  final SendPort parentSendPort;
  final ReceivePort childReceivePort;

  Emulator emulator;

  EmulatorIsolate(this.parentSendPort, this.childReceivePort);

  void main() async {
    parentSendPort.send(
      EmulatorMessageByChild(
        EmulatorMessageByChildType.INITIALIZE, 
        childReceivePort.sendPort
      )
    );

    _initEmulator();

    await for (var m in childReceivePort) {
      var message = m as EmulatorMessageByParent;
      switch(message.type) {
        case EmulatorMessageByParentType.START:
          _startEmulator(message.data as Uint8List);
          break;
        case EmulatorMessageByParentType.SET_DEBUG_CPU_LOG:
          _setDebugCPULog(message.data as String);
          break;
      }
    }
  }

  void _initEmulator() {
    emulator = new Emulator();
    emulator.onFrameChanged.listen((frame) {
      // フレーム更新を通知
      parentSendPort.send(
        EmulatorMessageByChild(
          EmulatorMessageByChildType.UPDATE_FRAME,
          frame
        )
      );
    });
  }

  void _startEmulator(Uint8List romBytes) {
    emulator.start(romBytes);
  }

  void _setDebugCPULog(String cpuLog) {
    emulator.debugCPULogs = cpuLog.split("\n");
  }
}
