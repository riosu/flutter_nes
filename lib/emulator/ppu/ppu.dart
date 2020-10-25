import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_nes/emulator/emulator.dart';
import 'package:flutter_nes/emulator/ppu/ppu_memory.dart';
import 'package:flutter_nes/emulator/ppu/ppu_registers.dart';


class Ppu {
  final Emulator emulator;

  PpuRegisters registers;
  PpuMemory mem;

  int cycle = 0;
  int line = 0;

  Ppu(this.emulator) {
    mem = new PpuMemory(emulator.rom);
    registers = new PpuRegisters(mem);
  }

  Uint8List run(int addCycle) {
    cycle += addCycle;

    // 1ライン341サイクルで描画
    if (cycle >= 341) {
      line++;
      cycle -= 341;

      // 262ラインで1画面
      if (line == 262) {
        line = 0;
        return _drawFrame();
      }
    }

    return null;
  }


  static const NES_WIDTH = 256;
  static const NES_HEIGHT = 240;
  static const NES_TILE_X = NES_WIDTH / 8;  // 32 = 0x20
  static const NES_TILE_Y = NES_HEIGHT / 8; // 30

  Uint8List _drawFrame() {
    // RGBA
    var frame = new Uint8List(NES_WIDTH * NES_HEIGHT * 4);

    // タイルごとに処理を行う
    for(int y = 0; y < NES_TILE_Y; y++) {
      for (int x = 0; x < NES_TILE_X; x++) {
        final address = 0x2000 + 0x20 * y + x;
        final spriteNumber = mem.read(address);
        final sprite = _getSprite(spriteNumber);

        // スプライト情報をフレームに描画する
        for (int i = 0; i < 8; i++) {
          for (int j = 0; j < 8; j++) {
            final offset = ((NES_WIDTH * (8 * y + i)) + (x * 8) + j) * 4;
            final spriteRaw = sprite[i * 8 + j];
            switch(spriteRaw) {
              case 0:
                frame[offset] = 0;
                frame[offset + 1] = 0;
                frame[offset + 2] = 0;
                frame[offset + 3] = 255;
                break;
              case 1:
                frame[offset] = 85;
                frame[offset + 1] = 85;
                frame[offset + 2] = 85;
                frame[offset + 3] = 255;
                break;
              case 2:
                frame[offset] = 170;
                frame[offset + 1] = 170;
                frame[offset + 2] = 170;
                frame[offset + 3] = 255;
                break;
              case 3:
                frame[offset] = 255;
                frame[offset + 1] = 255;
                frame[offset + 2] = 255;
                frame[offset + 3] = 255;
                break;
            }
          }
        }
        // stdout.write(spriteNumber.toRadixString(16).padLeft(2));
      }
      // stdout.write("\n");
    }

    return frame;
  }

  Uint8List _getSprite(int spriteNumber) {
    final sprite = new Uint8List(8 * 8);
    final spriteMemOffset = 0x10 * spriteNumber;

    for (int i = 0; i < 8; i++) {
      final s1 = mem.read(spriteMemOffset + i);
      final s2 = mem.read(spriteMemOffset + i + 8);

      for (int j = 0; j < 8; j++) {
        sprite[i * 8 + j] = (s1 >> (8 - j) & 1) + (s2 >> (8 -j) & 1) * 2;
      }
    }
    return sprite;
  }

}