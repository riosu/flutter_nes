import 'dart:typed_data';

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
    /*
    Parse INES Header
    -------------------------------
    0-3: Constant $4E $45 $53 $1A ("NES" followed by MS-DOS end-of-file)
    4: Size of PRG ROM in 16 KB units
    5: Size of CHR ROM in 8 KB units (Value 0 means the board uses CHR RAM)
    https://wiki.nesdev.com/w/index.php/INES
    */
    final prgUnitCount = rawBytes[4];
    final chrUnitCount = rawBytes[5];

    final prgRomStart = NES_HEADER_SIZE;
    final prgRomEnd = prgRomStart + prgUnitCount * NES_PROGRAM_UNIT_SIZE;
    this.prgRom = rawBytes.sublist(prgRomStart, prgRomEnd);

    final chrRomStart = prgRomEnd;
    final chrRomEnd = chrRomStart + chrUnitCount * NES_CHARACTOR_UNIT_SIZE; 
    this.chrRom = rawBytes.sublist(chrRomStart, chrRomEnd);
  }

  int readPrg(int address) {
    return prgRom[address];
  }

  int readChr(int address) {
    return chrRom[address];
  }
}
