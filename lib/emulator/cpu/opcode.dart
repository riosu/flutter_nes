
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

  OpInfo(this.op, this.mode);
}

// http://www.thealmightyguru.com/Games/Hacking/Wiki/index.php/6502_Opcodes
// BNEとかそのへんのアドレッシングモードの情報が間違っているようだ

// http://pgate1.at-ninja.jp/NES_on_FPGA/nes_cpu.htm#instruction

Map<int, OpInfo> _opMap = {
  0x69: OpInfo(OpType.ADC, OpAddressingMode.Immediate),
  0x65: OpInfo(OpType.ADC, OpAddressingMode.ZeroPage),
  0x75: OpInfo(OpType.ADC, OpAddressingMode.ZeroPageX),
  0x6D: OpInfo(OpType.ADC, OpAddressingMode.Absolute),
  0x7D: OpInfo(OpType.ADC, OpAddressingMode.AbsolutePageX),
  0x79: OpInfo(OpType.ADC, OpAddressingMode.AbsolutePageY),
  0x61: OpInfo(OpType.ADC, OpAddressingMode.IndexedIndirect),
  0x71: OpInfo(OpType.ADC, OpAddressingMode.IndirctIndexed),

  0x29: OpInfo(OpType.AND, OpAddressingMode.Immediate),
  0x25: OpInfo(OpType.AND, OpAddressingMode.ZeroPage),
  0x35: OpInfo(OpType.AND, OpAddressingMode.ZeroPageX),
  0x2D: OpInfo(OpType.AND, OpAddressingMode.Absolute),
  0x3D: OpInfo(OpType.AND, OpAddressingMode.AbsolutePageX),
  0x39: OpInfo(OpType.AND, OpAddressingMode.AbsolutePageY),
  0x21: OpInfo(OpType.AND, OpAddressingMode.IndexedIndirect),
  0x31: OpInfo(OpType.AND, OpAddressingMode.IndirctIndexed),

  0x0A: OpInfo(OpType.ASL, OpAddressingMode.Accumulator),
  0x06: OpInfo(OpType.ASL, OpAddressingMode.ZeroPage),
  0x16: OpInfo(OpType.ASL, OpAddressingMode.ZeroPageX),
  0x0E: OpInfo(OpType.ASL, OpAddressingMode.Absolute),
  0x1E: OpInfo(OpType.ASL, OpAddressingMode.AbsolutePageX),

  0x90: OpInfo(OpType.BCC, OpAddressingMode.Relative),

  0xB0: OpInfo(OpType.BCS, OpAddressingMode.Relative),

  0xF0: OpInfo(OpType.BEQ, OpAddressingMode.Relative),

  0x24: OpInfo(OpType.BIT, OpAddressingMode.ZeroPage),
  0x2C: OpInfo(OpType.BIT, OpAddressingMode.Absolute),

  0x30: OpInfo(OpType.BMI, OpAddressingMode.Relative),

  0xD0: OpInfo(OpType.BNE, OpAddressingMode.Relative),

  0x10: OpInfo(OpType.BPL, OpAddressingMode.Relative),

  0x00: OpInfo(OpType.BRK, OpAddressingMode.Implied),

  0x50: OpInfo(OpType.BVC, OpAddressingMode.Relative),

  0x70: OpInfo(OpType.BVS, OpAddressingMode.Relative),

  0x18: OpInfo(OpType.CLC, OpAddressingMode.Implied),

  0xD8: OpInfo(OpType.CLD, OpAddressingMode.Implied),

  0x58: OpInfo(OpType.CLI, OpAddressingMode.Implied),

  0xB8: OpInfo(OpType.CLV, OpAddressingMode.Implied),

  0xC9: OpInfo(OpType.CMP, OpAddressingMode.Immediate),
  0xC5: OpInfo(OpType.CMP, OpAddressingMode.ZeroPage),
  0xD5: OpInfo(OpType.CMP, OpAddressingMode.ZeroPageX),
  0xCD: OpInfo(OpType.CMP, OpAddressingMode.Absolute),
  0xDD: OpInfo(OpType.CMP, OpAddressingMode.AbsolutePageX),
  0xD9: OpInfo(OpType.CMP, OpAddressingMode.AbsolutePageY),
  0xC1: OpInfo(OpType.CMP, OpAddressingMode.IndexedIndirect),
  0xD1: OpInfo(OpType.CMP, OpAddressingMode.IndirctIndexed),

  0xE0: OpInfo(OpType.CPX, OpAddressingMode.Immediate),
  0xE4: OpInfo(OpType.CPX, OpAddressingMode.ZeroPage),
  0xEC: OpInfo(OpType.CPX, OpAddressingMode.Absolute),

  0xC0: OpInfo(OpType.CPY, OpAddressingMode.Immediate),
  0xC4: OpInfo(OpType.CPY, OpAddressingMode.ZeroPage),
  0xCC: OpInfo(OpType.CPY, OpAddressingMode.AbsolutePageY),

  0xC6: OpInfo(OpType.DEC, OpAddressingMode.ZeroPage),
  0xD6: OpInfo(OpType.DEC, OpAddressingMode.ZeroPageX),
  0xCE: OpInfo(OpType.DEC, OpAddressingMode.Absolute),
  0xDE: OpInfo(OpType.DEC, OpAddressingMode.AbsolutePageX),

  0xCA: OpInfo(OpType.DEX, OpAddressingMode.Implied),

  0x88: OpInfo(OpType.DEY, OpAddressingMode.Implied),

  0x49: OpInfo(OpType.EOR, OpAddressingMode.Immediate),
  0x45: OpInfo(OpType.EOR, OpAddressingMode.ZeroPage),
  0x55: OpInfo(OpType.EOR, OpAddressingMode.ZeroPageX),
  0x4D: OpInfo(OpType.EOR, OpAddressingMode.Absolute),
  0x5D: OpInfo(OpType.EOR, OpAddressingMode.AbsolutePageX),
  0x59: OpInfo(OpType.EOR, OpAddressingMode.AbsolutePageY),
  0x41: OpInfo(OpType.EOR, OpAddressingMode.IndexedIndirect),
  0x51: OpInfo(OpType.EOR, OpAddressingMode.IndirctIndexed),

  0xE6: OpInfo(OpType.INC, OpAddressingMode.ZeroPage),
  0xF6: OpInfo(OpType.INC, OpAddressingMode.ZeroPageX),
  0xEE: OpInfo(OpType.INC, OpAddressingMode.Absolute),
  0xFE: OpInfo(OpType.INC, OpAddressingMode.AbsolutePageX),

  0xE8: OpInfo(OpType.INX, OpAddressingMode.Implied),

  0xC8: OpInfo(OpType.INY, OpAddressingMode.Implied),

  0x6C: OpInfo(OpType.JMP, OpAddressingMode.AbsoluteIndirect),
  0x4C: OpInfo(OpType.JMP, OpAddressingMode.Absolute),

  0x20: OpInfo(OpType.JSR, OpAddressingMode.Absolute),

  0xA9: OpInfo(OpType.LDA, OpAddressingMode.Immediate),
  0xA5: OpInfo(OpType.LDA, OpAddressingMode.ZeroPage),
  0xB5: OpInfo(OpType.LDA, OpAddressingMode.ZeroPageX),
  0xAD: OpInfo(OpType.LDA, OpAddressingMode.Absolute),
  0xBD: OpInfo(OpType.LDA, OpAddressingMode.AbsolutePageX),
  0xB9: OpInfo(OpType.LDA, OpAddressingMode.AbsolutePageY),
  0xA1: OpInfo(OpType.LDA, OpAddressingMode.IndexedIndirect),
  0xB1: OpInfo(OpType.LDA, OpAddressingMode.IndirctIndexed),

  0xA6: OpInfo(OpType.LDX, OpAddressingMode.ZeroPage),
  0xB6: OpInfo(OpType.LDX, OpAddressingMode.ZeroPageX),
  0xAE: OpInfo(OpType.LDX, OpAddressingMode.Absolute),
  0xBE: OpInfo(OpType.LDX, OpAddressingMode.AbsolutePageY),
  0xA2: OpInfo(OpType.LDX, OpAddressingMode.Immediate),

  0xA0: OpInfo(OpType.LDY, OpAddressingMode.Immediate),
  0xA4: OpInfo(OpType.LDY, OpAddressingMode.ZeroPage),
  0xB4: OpInfo(OpType.LDY, OpAddressingMode.ZeroPageX),
  0xAC: OpInfo(OpType.LDY, OpAddressingMode.Absolute),
  0xBC: OpInfo(OpType.LDY, OpAddressingMode.AbsolutePageX),

  0x4A: OpInfo(OpType.LSR, OpAddressingMode.Accumulator),
  0x46: OpInfo(OpType.LSR, OpAddressingMode.ZeroPage),
  0x56: OpInfo(OpType.LSR, OpAddressingMode.ZeroPageX),
  0x4E: OpInfo(OpType.LSR, OpAddressingMode.Absolute),
  0x5E: OpInfo(OpType.LSR, OpAddressingMode.AbsolutePageX),

  0xEA: OpInfo(OpType.NOP, OpAddressingMode.Implied),

  0x09: OpInfo(OpType.ORA, OpAddressingMode.Immediate),
  0x05: OpInfo(OpType.ORA, OpAddressingMode.ZeroPage),
  0x15: OpInfo(OpType.ORA, OpAddressingMode.ZeroPageX),
  0x0D: OpInfo(OpType.ORA, OpAddressingMode.Absolute),
  0x1D: OpInfo(OpType.ORA, OpAddressingMode.AbsolutePageX),
  0x19: OpInfo(OpType.ORA, OpAddressingMode.AbsolutePageY),
  0x01: OpInfo(OpType.ORA, OpAddressingMode.IndexedIndirect),
  0x11: OpInfo(OpType.ORA, OpAddressingMode.IndirctIndexed),

  0x48: OpInfo(OpType.PHA, OpAddressingMode.Implied),

  0x08: OpInfo(OpType.PHP, OpAddressingMode.Implied),

  0x68: OpInfo(OpType.PLA, OpAddressingMode.Implied),

  0x28: OpInfo(OpType.PLP, OpAddressingMode.Implied),

  0x2A: OpInfo(OpType.ROL, OpAddressingMode.Accumulator),
  0x26: OpInfo(OpType.ROL, OpAddressingMode.ZeroPage),
  0x36: OpInfo(OpType.ROL, OpAddressingMode.ZeroPageX),
  0x2E: OpInfo(OpType.ROL, OpAddressingMode.Absolute),
  0x3E: OpInfo(OpType.ROL, OpAddressingMode.AbsolutePageX),

  0x6A: OpInfo(OpType.ROR, OpAddressingMode.Accumulator),
  0x66: OpInfo(OpType.ROR, OpAddressingMode.ZeroPage),
  0x76: OpInfo(OpType.ROR, OpAddressingMode.ZeroPageX),
  0x6E: OpInfo(OpType.ROR, OpAddressingMode.Absolute),
  0x7E: OpInfo(OpType.ROR, OpAddressingMode.AbsolutePageX),

  0x40: OpInfo(OpType.RTI, OpAddressingMode.Implied),

  0x60: OpInfo(OpType.RTS, OpAddressingMode.Implied),

  0xE9: OpInfo(OpType.SBC, OpAddressingMode.Immediate),
  0xE5: OpInfo(OpType.SBC, OpAddressingMode.ZeroPage),
  0xF5: OpInfo(OpType.SBC, OpAddressingMode.ZeroPageX),
  0xED: OpInfo(OpType.SBC, OpAddressingMode.Absolute),
  0xFD: OpInfo(OpType.SBC, OpAddressingMode.AbsolutePageX),
  0xF9: OpInfo(OpType.SBC, OpAddressingMode.AbsolutePageY),
  0xE1: OpInfo(OpType.SBC, OpAddressingMode.IndexedIndirect),
  0xF1: OpInfo(OpType.SBC, OpAddressingMode.IndirctIndexed),

  0x38: OpInfo(OpType.SEC, OpAddressingMode.Implied),

  0xF8: OpInfo(OpType.SED, OpAddressingMode.Implied),

  0x78: OpInfo(OpType.SEI, OpAddressingMode.Implied),

  0x85: OpInfo(OpType.STA, OpAddressingMode.ZeroPage),
  0x95: OpInfo(OpType.STA, OpAddressingMode.ZeroPageX),
  0x8D: OpInfo(OpType.STA, OpAddressingMode.Absolute),
  0x9D: OpInfo(OpType.STA, OpAddressingMode.AbsolutePageX),
  0x99: OpInfo(OpType.STA, OpAddressingMode.AbsolutePageY),
  0x81: OpInfo(OpType.STA, OpAddressingMode.IndexedIndirect),
  0x91: OpInfo(OpType.STA, OpAddressingMode.IndirctIndexed),

  0x86: OpInfo(OpType.STX, OpAddressingMode.ZeroPage),
  0x96: OpInfo(OpType.STX, OpAddressingMode.ZeroPageX),
  0x8E: OpInfo(OpType.STX, OpAddressingMode.Absolute),

  0x84: OpInfo(OpType.STY, OpAddressingMode.ZeroPage),
  0x94: OpInfo(OpType.STY, OpAddressingMode.ZeroPageX),
  0x8C: OpInfo(OpType.STY, OpAddressingMode.Absolute),

  0xAA: OpInfo(OpType.TAX, OpAddressingMode.Implied),

  0xA8: OpInfo(OpType.TAY, OpAddressingMode.Implied),

  0xBA: OpInfo(OpType.TSX, OpAddressingMode.Implied),

  0x8A: OpInfo(OpType.TXA, OpAddressingMode.Implied),

  0x9A: OpInfo(OpType.TXS, OpAddressingMode.Implied),

  0x98: OpInfo(OpType.TYA, OpAddressingMode.Implied),
};
