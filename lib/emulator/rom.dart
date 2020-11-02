import 'dart:typed_data';

import 'package:flutter_nes/utils/logger.dart';

const NES_HEADER_SIZE = 0x0010;
const NES_PROGRAM_UNIT_SIZE = 0x4000;
const NES_CHARACTOR_UNIT_SIZE = 0x2000;

class Rom {
  Uint8List prgRom;
  Uint8List chrRom;

  Rom(Uint8List rawBytes) {
    _parseRom(rawBytes);
  }

  _parseRom(Uint8List rawBytes) {
    final prgUnitCount = rawBytes[4];
    final chrUnitCount = rawBytes[5];

    final prgRomStart = NES_HEADER_SIZE;
    final prgRomEnd = prgRomStart + prgUnitCount * NES_PROGRAM_UNIT_SIZE;
    prgRom = rawBytes.sublist(prgRomStart, prgRomEnd);

    final chrRomStart = prgRomEnd;
    final chrRomEnd = chrRomStart + chrUnitCount * NES_CHARACTOR_UNIT_SIZE; 
    chrRom = rawBytes.sublist(chrRomStart, chrRomEnd);

    if (prgUnitCount == 1) {
      // プログラムROMが1ユニットしかない場合、0xC000~0x8000へのアクセスを可能にするためにコピーする
      prgRom = Uint8List.fromList(prgRom + prgRom);
    }

    Logger.debug("Load ROM: prgUnitCount: $prgUnitCount, chrUnitCount: $chrUnitCount");
  }

  int readPrg(int address) {
    return prgRom[address];
  }

  int readChr(int address) {
    return chrRom[address];
  }
}
