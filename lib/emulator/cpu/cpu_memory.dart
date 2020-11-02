import 'dart:typed_data';

import 'package:flutter_nes/emulator/emulator.dart';
import 'package:flutter_nes/emulator/errors.dart';

class CpuMemory {
  final Emulator emulator;

  final wram = new Uint8List(0x0800);

  CpuMemory(this.emulator);

  int read(int address) {
    if (address < 0x0800) {
      // WRAM
      return wram[address];

    } else if (address < 0x2000) {
      // WRAMのミラー
      throw new MemoryAccessNotImplementedError(MemoryAccessType.CPU, address);
    
    } else if (address < 0x2008) {
      // PPUレジスタ
      throw new MemoryAccessNotImplementedError(MemoryAccessType.CPU, address);
    
    } else if (address < 0x4000) {
      // PPUレジスタのミラー
      throw new MemoryAccessNotImplementedError(MemoryAccessType.CPU, address);
    
    } else if (address < 0x4020) {
      // API I/O, PAD
      return 0xFF;
      // throw new MemoryAccessNotImplementedError(MemoryAccessType.CPU, address);
    
    } else if (address < 0x6000) {
      // 拡張ROM
      throw new MemoryAccessNotImplementedError(MemoryAccessType.CPU, address);
    
    } else if (address < 0x8000) {
      // 拡張RAM
      throw new MemoryAccessNotImplementedError(MemoryAccessType.CPU, address);

    }
    else if (address < 0xFFFF) {
      // PRG-ROM
      return emulator.rom.readPrg(address - 0x8000);
    }

    throw new MemoryAccessError(MemoryAccessType.CPU, address);
  }

  void write(int address, int data) {
    if (address < 0x0800) {
      // WRAM
      wram[address] = data;
      return;

    } else if (address < 0x2000) {
      // WRAMのミラー
      throw new MemoryAccessNotImplementedError(MemoryAccessType.CPU, address);

    } else if (address < 0x2008) {
      // PPUレジスタ
      switch(address) {
        case 0x2000: 
          // PPUCTRL
          emulator.ppu.registers.ppuCtrl = data;
          return;
        case 0x2001:
          // PPUMASK
          emulator.ppu.registers.ppuMask = data;
          return;
        case 0x2002:
          // PPUSTATUS
          emulator.ppu.registers.ppuStatus = data;
          return;
        case 0x2003:
          // OAMADDR
          emulator.ppu.registers.oamAddr = data;
          return;
        case 0x2004:
          // OAMDATA
          emulator.ppu.registers.oamData = data;
          return;
        case 0x2005:
          // PPUSCROLL
          emulator.ppu.registers.ppuScroll = data;
          return;
        case 0x2006:
          // PPUADDR
          emulator.ppu.registers.ppuAddr = data;
          return;
        case 0x2007:
          // PPUDATA
          emulator.ppu.registers.ppuData = data;  
          return;
      }
    } else if (address < 0x4016) {
      return;
    }

    throw new MemoryAccessError(MemoryAccessType.CPU, address);
  }
}
