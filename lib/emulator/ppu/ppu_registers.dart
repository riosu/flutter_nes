
import 'package:flutter_nes/emulator/ppu/ppu_memory.dart';

class PpuRegisters {
  final PpuMemory mem;
  PpuRegisters(this.mem);

  int ppuCtrl = 0;
  int ppuMask = 0;
  int ppuStatus = 0;
  int oamAddr = 0;
  int oamData = 0;
  int ppuScroll = 0;

  // PPUADDR (Write)
  bool _ppuAddrCallFirst = true;
  int _ppuAddr = 0;
  set ppuAddr(int data) {
    if (_ppuAddrCallFirst) {
      _ppuAddr = data << 8 | _ppuAddr & 0x00FF;
      _ppuAddrCallFirst = false;
    } else {
      _ppuAddr = _ppuAddr & 0xFF00 | data;
      _ppuAddrCallFirst = true;
    }
  }

  // PPUDATA (Read/Write)
  int get ppuData { 
    final data = mem.read(_ppuAddr);
    _incrementPpuAddr();
    return data;
  }
  set ppuData(int data) {
    mem.write(_ppuAddr, data);
    _incrementPpuAddr();
  }

  void _incrementPpuAddr() {
    // PPUDATAからREAD/WRITEする際に、PPUADDRをインクリメントする
    // 0x2000のビット2によって、+1するか+32するか決定するらしいが、とりあえず+1する
    _ppuAddr++;
  }
}
