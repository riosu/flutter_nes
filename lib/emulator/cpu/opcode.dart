
import 'package:flutter_nes/emulator/errors.dart';

class OpCode {
  static OpInfo getInfo(int opCode) {
    var info = _opMap[opCode];
    if (info == null) {
      throw new UnknownOpCodeError(opCode);
    }
    return info;
  }
}

enum OpType {
  ADC,
  AND,
  ASL,
  BCC,
  BCS,
  BEQ,
  BIT,
  BMI,
  BNE,
  BPL,
  BRK,
  BVC,
  BVS,
  CLC,
  CLD,
  CLI,
  CLV,
  CMP,
  CPX,
  CPY,
  DEC,
  DEX,
  DEY,
  EOR,
  INC,
  INX,
  INY,
  JMP,
  JSR,
  LDA,
  LDX,
  LDY,
  LSR,
  NOP,
  ORA,
  PHA,
  PHP,
  PLA,
  PLP,
  ROL,
  ROR,
  RTI,
  RTS,
  SBC,
  SEC,
  SED,
  SEI,
  STA,
  STX,
  STY,
  TAX,
  TAY,
  TSX,
  TXA,
  TXS,
  TYA,

  // Unofficial opcodes
  LAX,
  SAX,
  DCP,
  ISB,
  SLO,
  RLA,
  SRE,
  RRA
}

enum OpAddressingMode {
  Implied,
  Accumulator,
  Immediate,
  ZeroPage,
  ZeroPageX,
  ZeroPageY,
  Absolute,
  AbsolutePageX,
  AbsolutePageY,
  Relative,
  IndexedIndirect,  // preIndexed, (Indirect, X)
  IndirctIndexed,   // postIndeed, (Indirect) Y
  AbsoluteIndirect, // Indirect
}

class OpInfo {
  final OpType op;
  final OpAddressingMode mode;
  final int cycle;

  OpInfo(this.op, this.mode, this.cycle);
}

// http://www.thealmightyguru.com/Games/Hacking/Wiki/index.php/6502_Opcodes
// BNEとかそのへんのアドレッシングモードの情報が間違っているようだ

// http://pgate1.at-ninja.jp/NES_on_FPGA/nes_cpu.htm#instruction

Map<int, OpInfo> _opMap = {
  0x69: OpInfo(OpType.ADC, OpAddressingMode.Immediate, 2),
  0x65: OpInfo(OpType.ADC, OpAddressingMode.ZeroPage, 3),
  0x75: OpInfo(OpType.ADC, OpAddressingMode.ZeroPageX, 4),
  0x6D: OpInfo(OpType.ADC, OpAddressingMode.Absolute, 4),
  0x7D: OpInfo(OpType.ADC, OpAddressingMode.AbsolutePageX, 4),
  0x79: OpInfo(OpType.ADC, OpAddressingMode.AbsolutePageY, 4),
  0x61: OpInfo(OpType.ADC, OpAddressingMode.IndexedIndirect, 6),
  0x71: OpInfo(OpType.ADC, OpAddressingMode.IndirctIndexed, 5),

  0x29: OpInfo(OpType.AND, OpAddressingMode.Immediate, 2),
  0x25: OpInfo(OpType.AND, OpAddressingMode.ZeroPage, 3),
  0x35: OpInfo(OpType.AND, OpAddressingMode.ZeroPageX, 4),
  0x2D: OpInfo(OpType.AND, OpAddressingMode.Absolute, 4),
  0x3D: OpInfo(OpType.AND, OpAddressingMode.AbsolutePageX, 4),
  0x39: OpInfo(OpType.AND, OpAddressingMode.AbsolutePageY, 4),
  0x21: OpInfo(OpType.AND, OpAddressingMode.IndexedIndirect, 6),
  0x31: OpInfo(OpType.AND, OpAddressingMode.IndirctIndexed, 5),

  0x0A: OpInfo(OpType.ASL, OpAddressingMode.Accumulator, 2),
  0x06: OpInfo(OpType.ASL, OpAddressingMode.ZeroPage, 5),
  0x16: OpInfo(OpType.ASL, OpAddressingMode.ZeroPageX, 6),
  0x0E: OpInfo(OpType.ASL, OpAddressingMode.Absolute, 6),
  0x1E: OpInfo(OpType.ASL, OpAddressingMode.AbsolutePageX, 7),

  0x90: OpInfo(OpType.BCC, OpAddressingMode.Relative, 2),

  0xB0: OpInfo(OpType.BCS, OpAddressingMode.Relative, 2),

  0xF0: OpInfo(OpType.BEQ, OpAddressingMode.Relative, 2),

  0x24: OpInfo(OpType.BIT, OpAddressingMode.ZeroPage, 3),
  0x2C: OpInfo(OpType.BIT, OpAddressingMode.Absolute, 4),

  0x30: OpInfo(OpType.BMI, OpAddressingMode.Relative, 2),

  0xD0: OpInfo(OpType.BNE, OpAddressingMode.Relative, 2),

  0x10: OpInfo(OpType.BPL, OpAddressingMode.Relative, 2),

  0x00: OpInfo(OpType.BRK, OpAddressingMode.Implied, 7),

  0x50: OpInfo(OpType.BVC, OpAddressingMode.Relative, 2),

  0x70: OpInfo(OpType.BVS, OpAddressingMode.Relative, 2),

  0x18: OpInfo(OpType.CLC, OpAddressingMode.Implied, 2),

  0xD8: OpInfo(OpType.CLD, OpAddressingMode.Implied, 2),

  0x58: OpInfo(OpType.CLI, OpAddressingMode.Implied, 2),

  0xB8: OpInfo(OpType.CLV, OpAddressingMode.Implied, 2),

  0xC9: OpInfo(OpType.CMP, OpAddressingMode.Immediate, 2),
  0xC5: OpInfo(OpType.CMP, OpAddressingMode.ZeroPage, 3),
  0xD5: OpInfo(OpType.CMP, OpAddressingMode.ZeroPageX, 4),
  0xCD: OpInfo(OpType.CMP, OpAddressingMode.Absolute, 4),
  0xDD: OpInfo(OpType.CMP, OpAddressingMode.AbsolutePageX, 4),
  0xD9: OpInfo(OpType.CMP, OpAddressingMode.AbsolutePageY, 4),
  0xC1: OpInfo(OpType.CMP, OpAddressingMode.IndexedIndirect, 6),
  0xD1: OpInfo(OpType.CMP, OpAddressingMode.IndirctIndexed, 5),

  0xE0: OpInfo(OpType.CPX, OpAddressingMode.Immediate, 2),
  0xE4: OpInfo(OpType.CPX, OpAddressingMode.ZeroPage, 3),
  0xEC: OpInfo(OpType.CPX, OpAddressingMode.Absolute, 4),

  0xC0: OpInfo(OpType.CPY, OpAddressingMode.Immediate, 2),
  0xC4: OpInfo(OpType.CPY, OpAddressingMode.ZeroPage, 3),
  0xCC: OpInfo(OpType.CPY, OpAddressingMode.Absolute, 4),

  0xC6: OpInfo(OpType.DEC, OpAddressingMode.ZeroPage, 5),
  0xD6: OpInfo(OpType.DEC, OpAddressingMode.ZeroPageX, 6),
  0xCE: OpInfo(OpType.DEC, OpAddressingMode.Absolute, 6),
  0xDE: OpInfo(OpType.DEC, OpAddressingMode.AbsolutePageX, 7),

  0xCA: OpInfo(OpType.DEX, OpAddressingMode.Implied, 2),

  0x88: OpInfo(OpType.DEY, OpAddressingMode.Implied, 2),

  0x49: OpInfo(OpType.EOR, OpAddressingMode.Immediate, 2),
  0x45: OpInfo(OpType.EOR, OpAddressingMode.ZeroPage, 3),
  0x55: OpInfo(OpType.EOR, OpAddressingMode.ZeroPageX, 4),
  0x4D: OpInfo(OpType.EOR, OpAddressingMode.Absolute, 4),
  0x5D: OpInfo(OpType.EOR, OpAddressingMode.AbsolutePageX, 4),
  0x59: OpInfo(OpType.EOR, OpAddressingMode.AbsolutePageY, 4),
  0x41: OpInfo(OpType.EOR, OpAddressingMode.IndexedIndirect, 6),
  0x51: OpInfo(OpType.EOR, OpAddressingMode.IndirctIndexed, 5),

  0xE6: OpInfo(OpType.INC, OpAddressingMode.ZeroPage, 5),
  0xF6: OpInfo(OpType.INC, OpAddressingMode.ZeroPageX, 6),
  0xEE: OpInfo(OpType.INC, OpAddressingMode.Absolute, 6),
  0xFE: OpInfo(OpType.INC, OpAddressingMode.AbsolutePageX, 7),

  0xE8: OpInfo(OpType.INX, OpAddressingMode.Implied, 2),

  0xC8: OpInfo(OpType.INY, OpAddressingMode.Implied, 2),

  0x6C: OpInfo(OpType.JMP, OpAddressingMode.AbsoluteIndirect, 3),
  0x4C: OpInfo(OpType.JMP, OpAddressingMode.Absolute, 5),

  0x20: OpInfo(OpType.JSR, OpAddressingMode.Absolute, 6),

  0xA9: OpInfo(OpType.LDA, OpAddressingMode.Immediate, 2),
  0xA5: OpInfo(OpType.LDA, OpAddressingMode.ZeroPage, 3),
  0xB5: OpInfo(OpType.LDA, OpAddressingMode.ZeroPageX, 4),
  0xAD: OpInfo(OpType.LDA, OpAddressingMode.Absolute, 4),
  0xBD: OpInfo(OpType.LDA, OpAddressingMode.AbsolutePageX, 4),
  0xB9: OpInfo(OpType.LDA, OpAddressingMode.AbsolutePageY, 4),
  0xA1: OpInfo(OpType.LDA, OpAddressingMode.IndexedIndirect, 6),
  0xB1: OpInfo(OpType.LDA, OpAddressingMode.IndirctIndexed, 5),

  0xA6: OpInfo(OpType.LDX, OpAddressingMode.ZeroPage, 2),
  0xB6: OpInfo(OpType.LDX, OpAddressingMode.ZeroPageY, 3),
  0xAE: OpInfo(OpType.LDX, OpAddressingMode.Absolute, 4),
  0xBE: OpInfo(OpType.LDX, OpAddressingMode.AbsolutePageY, 4),
  0xA2: OpInfo(OpType.LDX, OpAddressingMode.Immediate, 4),

  0xA0: OpInfo(OpType.LDY, OpAddressingMode.Immediate, 2),
  0xA4: OpInfo(OpType.LDY, OpAddressingMode.ZeroPage, 3),
  0xB4: OpInfo(OpType.LDY, OpAddressingMode.ZeroPageX, 4),
  0xAC: OpInfo(OpType.LDY, OpAddressingMode.Absolute, 4),
  0xBC: OpInfo(OpType.LDY, OpAddressingMode.AbsolutePageX, 4),

  0x4A: OpInfo(OpType.LSR, OpAddressingMode.Accumulator, 2),
  0x46: OpInfo(OpType.LSR, OpAddressingMode.ZeroPage, 5),
  0x56: OpInfo(OpType.LSR, OpAddressingMode.ZeroPageX, 6),
  0x4E: OpInfo(OpType.LSR, OpAddressingMode.Absolute, 6),
  0x5E: OpInfo(OpType.LSR, OpAddressingMode.AbsolutePageX, 7),

  0xEA: OpInfo(OpType.NOP, OpAddressingMode.Implied, 2),

  0x09: OpInfo(OpType.ORA, OpAddressingMode.Immediate, 2),
  0x05: OpInfo(OpType.ORA, OpAddressingMode.ZeroPage, 3),
  0x15: OpInfo(OpType.ORA, OpAddressingMode.ZeroPageX, 4),
  0x0D: OpInfo(OpType.ORA, OpAddressingMode.Absolute, 4),
  0x1D: OpInfo(OpType.ORA, OpAddressingMode.AbsolutePageX, 4),
  0x19: OpInfo(OpType.ORA, OpAddressingMode.AbsolutePageY, 4),
  0x01: OpInfo(OpType.ORA, OpAddressingMode.IndexedIndirect, 6),
  0x11: OpInfo(OpType.ORA, OpAddressingMode.IndirctIndexed, 5),

  0x48: OpInfo(OpType.PHA, OpAddressingMode.Implied, 3),

  0x08: OpInfo(OpType.PHP, OpAddressingMode.Implied, 3),

  0x68: OpInfo(OpType.PLA, OpAddressingMode.Implied, 4),

  0x28: OpInfo(OpType.PLP, OpAddressingMode.Implied, 4),

  0x2A: OpInfo(OpType.ROL, OpAddressingMode.Accumulator, 2),
  0x26: OpInfo(OpType.ROL, OpAddressingMode.ZeroPage, 5),
  0x36: OpInfo(OpType.ROL, OpAddressingMode.ZeroPageX, 6),
  0x2E: OpInfo(OpType.ROL, OpAddressingMode.Absolute, 6),
  0x3E: OpInfo(OpType.ROL, OpAddressingMode.AbsolutePageX, 7),

  0x6A: OpInfo(OpType.ROR, OpAddressingMode.Accumulator, 2),
  0x66: OpInfo(OpType.ROR, OpAddressingMode.ZeroPage, 5),
  0x76: OpInfo(OpType.ROR, OpAddressingMode.ZeroPageX, 6),
  0x6E: OpInfo(OpType.ROR, OpAddressingMode.Absolute, 6),
  0x7E: OpInfo(OpType.ROR, OpAddressingMode.AbsolutePageX, 7),

  0x40: OpInfo(OpType.RTI, OpAddressingMode.Implied, 6),

  0x60: OpInfo(OpType.RTS, OpAddressingMode.Implied, 6),

  0xE9: OpInfo(OpType.SBC, OpAddressingMode.Immediate, 2),
  0xE5: OpInfo(OpType.SBC, OpAddressingMode.ZeroPage, 3),
  0xF5: OpInfo(OpType.SBC, OpAddressingMode.ZeroPageX, 4),
  0xED: OpInfo(OpType.SBC, OpAddressingMode.Absolute, 4),
  0xFD: OpInfo(OpType.SBC, OpAddressingMode.AbsolutePageX, 4),
  0xF9: OpInfo(OpType.SBC, OpAddressingMode.AbsolutePageY, 4),
  0xE1: OpInfo(OpType.SBC, OpAddressingMode.IndexedIndirect, 6),
  0xF1: OpInfo(OpType.SBC, OpAddressingMode.IndirctIndexed, 5),

  0x38: OpInfo(OpType.SEC, OpAddressingMode.Implied, 2),

  0xF8: OpInfo(OpType.SED, OpAddressingMode.Implied, 2),

  0x78: OpInfo(OpType.SEI, OpAddressingMode.Implied, 2),

  0x85: OpInfo(OpType.STA, OpAddressingMode.ZeroPage, 3),
  0x95: OpInfo(OpType.STA, OpAddressingMode.ZeroPageX, 4),
  0x8D: OpInfo(OpType.STA, OpAddressingMode.Absolute, 4),
  0x9D: OpInfo(OpType.STA, OpAddressingMode.AbsolutePageX, 5),
  0x99: OpInfo(OpType.STA, OpAddressingMode.AbsolutePageY, 5),
  0x81: OpInfo(OpType.STA, OpAddressingMode.IndexedIndirect, 6),
  0x91: OpInfo(OpType.STA, OpAddressingMode.IndirctIndexed, 6),

  0x86: OpInfo(OpType.STX, OpAddressingMode.ZeroPage, 3),
  0x96: OpInfo(OpType.STX, OpAddressingMode.ZeroPageY, 4),
  0x8E: OpInfo(OpType.STX, OpAddressingMode.Absolute, 4),

  0x84: OpInfo(OpType.STY, OpAddressingMode.ZeroPage, 3),
  0x94: OpInfo(OpType.STY, OpAddressingMode.ZeroPageX, 4),
  0x8C: OpInfo(OpType.STY, OpAddressingMode.Absolute, 4),

  0xAA: OpInfo(OpType.TAX, OpAddressingMode.Implied, 2),

  0xA8: OpInfo(OpType.TAY, OpAddressingMode.Implied, 2),

  0xBA: OpInfo(OpType.TSX, OpAddressingMode.Implied, 2),

  0x8A: OpInfo(OpType.TXA, OpAddressingMode.Implied, 2),

  0x9A: OpInfo(OpType.TXS, OpAddressingMode.Implied, 2),

  0x98: OpInfo(OpType.TYA, OpAddressingMode.Implied, 2),

  // Unofficial opcodes
  0xA3: OpInfo(OpType.LAX, OpAddressingMode.IndexedIndirect, 6),
  0xA7: OpInfo(OpType.LAX, OpAddressingMode.ZeroPage, 3),
  0xAF: OpInfo(OpType.LAX, OpAddressingMode.Absolute, 4),
  0xB3: OpInfo(OpType.LAX, OpAddressingMode.IndirctIndexed, 5),
  0xB7: OpInfo(OpType.LAX, OpAddressingMode.ZeroPageY, 4),
  0xBF: OpInfo(OpType.LAX, OpAddressingMode.AbsolutePageY, 4),
  
  0x83: OpInfo(OpType.SAX, OpAddressingMode.IndexedIndirect, 6),
  0x87: OpInfo(OpType.SAX, OpAddressingMode.ZeroPage, 3),
  0x8F: OpInfo(OpType.SAX, OpAddressingMode.Absolute, 4),
  0x97: OpInfo(OpType.SAX, OpAddressingMode.ZeroPageY, 4),

  0xEB: OpInfo(OpType.SBC, OpAddressingMode.Immediate, 2),

  0xC3: OpInfo(OpType.DCP, OpAddressingMode.IndexedIndirect, 8),
  0xC7: OpInfo(OpType.DCP, OpAddressingMode.ZeroPage, 5),
  0xCF: OpInfo(OpType.DCP, OpAddressingMode.Absolute, 6),
  0xD3: OpInfo(OpType.DCP, OpAddressingMode.IndirctIndexed, 8),
  0xD7: OpInfo(OpType.DCP, OpAddressingMode.ZeroPageX, 6),
  0xDB: OpInfo(OpType.DCP, OpAddressingMode.AbsolutePageY, 7),
  0xDF: OpInfo(OpType.DCP, OpAddressingMode.AbsolutePageX, 7),

  0xE3: OpInfo(OpType.ISB, OpAddressingMode.IndexedIndirect, 8),
  0xE7: OpInfo(OpType.ISB, OpAddressingMode.ZeroPage, 5),
  0xEF: OpInfo(OpType.ISB, OpAddressingMode.Absolute, 6),
  0xF3: OpInfo(OpType.ISB, OpAddressingMode.IndirctIndexed, 8),
  0xF7: OpInfo(OpType.ISB, OpAddressingMode.ZeroPageX, 6),
  0xFB: OpInfo(OpType.ISB, OpAddressingMode.AbsolutePageY, 7),
  0xFF: OpInfo(OpType.ISB, OpAddressingMode.AbsolutePageX, 7),

  0x03: OpInfo(OpType.SLO, OpAddressingMode.IndexedIndirect, 8),
  0x07: OpInfo(OpType.SLO, OpAddressingMode.ZeroPage, 5),
  0x0F: OpInfo(OpType.SLO, OpAddressingMode.Absolute, 6),
  0x13: OpInfo(OpType.SLO, OpAddressingMode.IndirctIndexed, 8),
  0x17: OpInfo(OpType.SLO, OpAddressingMode.ZeroPageX, 6),
  0x1B: OpInfo(OpType.SLO, OpAddressingMode.AbsolutePageY, 7),
  0x1F: OpInfo(OpType.SLO, OpAddressingMode.AbsolutePageX, 7),

  0x23: OpInfo(OpType.RLA, OpAddressingMode.IndexedIndirect, 8),
  0x27: OpInfo(OpType.RLA, OpAddressingMode.ZeroPage, 5),
  0x2F: OpInfo(OpType.RLA, OpAddressingMode.Absolute, 6),
  0x33: OpInfo(OpType.RLA, OpAddressingMode.IndirctIndexed, 8),
  0x37: OpInfo(OpType.RLA, OpAddressingMode.ZeroPageX, 6),
  0x3B: OpInfo(OpType.RLA, OpAddressingMode.AbsolutePageY, 7),
  0x3F: OpInfo(OpType.RLA, OpAddressingMode.AbsolutePageX, 7),

  0x43: OpInfo(OpType.SRE, OpAddressingMode.IndexedIndirect, 8),
  0x47: OpInfo(OpType.SRE, OpAddressingMode.ZeroPage, 5),
  0x4F: OpInfo(OpType.SRE, OpAddressingMode.Absolute, 6),
  0x53: OpInfo(OpType.SRE, OpAddressingMode.IndirctIndexed, 8),
  0x57: OpInfo(OpType.SRE, OpAddressingMode.ZeroPageX, 6),
  0x5B: OpInfo(OpType.SRE, OpAddressingMode.AbsolutePageY, 7),
  0x5F: OpInfo(OpType.SRE, OpAddressingMode.AbsolutePageX, 7),

  0x63: OpInfo(OpType.RRA, OpAddressingMode.IndexedIndirect, 8),
  0x67: OpInfo(OpType.RRA, OpAddressingMode.ZeroPage, 5),
  0x6F: OpInfo(OpType.RRA, OpAddressingMode.Absolute, 6),
  0x73: OpInfo(OpType.RRA, OpAddressingMode.IndirctIndexed, 8),
  0x77: OpInfo(OpType.RRA, OpAddressingMode.ZeroPageX, 6),
  0x7B: OpInfo(OpType.RRA, OpAddressingMode.AbsolutePageY, 7),
  0x7F: OpInfo(OpType.RRA, OpAddressingMode.AbsolutePageX, 7),

  0x1A: OpInfo(OpType.NOP, OpAddressingMode.Implied, 2),
  0x3A: OpInfo(OpType.NOP, OpAddressingMode.Implied, 2),
  0x5A: OpInfo(OpType.NOP, OpAddressingMode.Implied, 2),
  0x7A: OpInfo(OpType.NOP, OpAddressingMode.Implied, 2),
  0xDA: OpInfo(OpType.NOP, OpAddressingMode.Implied, 2),
  0xFA: OpInfo(OpType.NOP, OpAddressingMode.Implied, 2),

  // SKB (NOPと同様なにも処理しないが、もうひとつFetchする)
  0x80: OpInfo(OpType.NOP, OpAddressingMode.Immediate, 2),
  0x82: OpInfo(OpType.NOP, OpAddressingMode.Immediate, 2),
  0x89: OpInfo(OpType.NOP, OpAddressingMode.Immediate, 2),
  0xC2: OpInfo(OpType.NOP, OpAddressingMode.Immediate, 2),
  0xE2: OpInfo(OpType.NOP, OpAddressingMode.Immediate, 2),

  // IGN (NOPと同様なにも処理しないが、メモリから値を読み込む)
  0x0C: OpInfo(OpType.NOP, OpAddressingMode.Absolute, 4),
  0x1C: OpInfo(OpType.NOP, OpAddressingMode.AbsolutePageX, 4),
  0x3C: OpInfo(OpType.NOP, OpAddressingMode.AbsolutePageX, 4),
  0x5C: OpInfo(OpType.NOP, OpAddressingMode.AbsolutePageX, 4),
  0x7C: OpInfo(OpType.NOP, OpAddressingMode.AbsolutePageX, 4),
  0xDC: OpInfo(OpType.NOP, OpAddressingMode.AbsolutePageX, 4),
  0xFC: OpInfo(OpType.NOP, OpAddressingMode.AbsolutePageX, 4),
  0x04: OpInfo(OpType.NOP, OpAddressingMode.ZeroPage, 3),
  0x44: OpInfo(OpType.NOP, OpAddressingMode.ZeroPage, 3),
  0x64: OpInfo(OpType.NOP, OpAddressingMode.ZeroPage, 3),
  0x14: OpInfo(OpType.NOP, OpAddressingMode.ZeroPageX, 4),
  0x34: OpInfo(OpType.NOP, OpAddressingMode.ZeroPageX, 4),
  0x54: OpInfo(OpType.NOP, OpAddressingMode.ZeroPageX, 4),
  0x74: OpInfo(OpType.NOP, OpAddressingMode.ZeroPageX, 4),
  0xD4: OpInfo(OpType.NOP, OpAddressingMode.ZeroPageX, 4),
  0xF4: OpInfo(OpType.NOP, OpAddressingMode.ZeroPageX, 4),
};
