
import 'dart:typed_data';

import 'package:flutter_nes/emulator/errors.dart';
import 'package:flutter_nes/emulator/rom.dart';

class PpuMemory {
  final Rom rom;
  final vram = new Uint8List(0x1000);
  final pallete = new Uint8List(0x100);

  PpuMemory(this.rom);

  int read(int address) {
    if (address < 0x1000) {
      // パターンテーブル 0
      return rom.readChr(address);

    } else if (address < 0x2000) {
      // パターンテーブル 1
      return rom.readChr(address);

    } else if (address < 0x3000) {
      // ネームテーブル・属性テーブル
      return vram[address - 0x2000];

    } else if (address < 0x3F00) {
      // ネームテーブル・属性テーブルのミラー
      throw new MemoryAccessNotImplementedError(MemoryAccessType.PPU, address);

    } else if (address < 0x3F20) {
      // パレット
      return pallete[address - 0x3F00];

    } else if (address < 0x4000) {
      // パレットのミラー
      return pallete[(address - 0x3F20) % 0x10];
    }

    throw new MemoryAccessError(MemoryAccessType.PPU, address);
  }

  void write(int address, int data) {
    if (address >= 0x2000 && address < 0x3000) {
      // ネームテーブル・属性テーブル
      vram[address - 0x2000] = data;
      return;

    } else if (address >= 0x3F00 && address < 0x3F20) {
      // パレット
      pallete[address - 0x3F00] = data;
      return;
    }

    throw new MemoryAccessError(MemoryAccessType.PPU, address);
  }
}
