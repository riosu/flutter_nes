
import 'dart:async';

import 'package:flutter_nes/emulator/cpu/cpu.dart';
import 'package:flutter_nes/emulator/ppu/ppu.dart';
import 'package:flutter_nes/emulator/rom.dart';
import 'dart:typed_data';

class Emulator {

  bool isRunning = false;

  Rom rom;
  Cpu cpu;
  Ppu ppu;

  List<String> debugCPULogs;

  final _onFrameChanedController = new StreamController.broadcast();
  Stream get onFrameChanged => _onFrameChanedController.stream;

  void start(Uint8List romBytes) {
    isRunning = true;

    rom = new Rom(romBytes);
    cpu = new Cpu(this);
    ppu = new Ppu(this);

    Timer.periodic(Duration(milliseconds: 16), _executeFrame);
  }

  void dispose() {
    isRunning = false;
    _onFrameChanedController.close();
  }

  void _executeFrame(Timer timer) {
    try {
      while (isRunning) {
        var cycle = cpu.run();
        var renderPixels = ppu.run(cycle * 3);

        // ピクセル情報が帰ってきている場合
        if (renderPixels != null) {
          // ピクセル情報をWidgetにStreamを使って返送し、描画させる
          _onFrameChanedController.add(renderPixels);
          break;
        }
      }

    } catch (error, stackTrace) {
      print("Timer Canceled: $error");
      print(stackTrace);

      timer.cancel();
    }
  }


}
