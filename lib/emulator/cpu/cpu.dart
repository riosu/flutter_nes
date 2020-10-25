
import 'dart:typed_data';

import 'package:flutter_nes/emulator/cpu/cpu_memory.dart';
import 'package:flutter_nes/emulator/cpu/cpu_registers.dart';
import 'package:flutter_nes/emulator/cpu/opcode.dart';
import 'package:flutter_nes/emulator/emulator.dart';
import 'package:flutter_nes/emulator/errors.dart';

class Cpu {
  final Emulator emulator;

  CpuRegisters registers;
  CpuMemory mem;

  Cpu(this.emulator) {
    registers = new CpuRegisters();
    mem = new CpuMemory(emulator);
    _interuptReset();
  }

  int run() {
    var debugCurrentPC = registers.pc;

    var opCode = _fetchPC();
    var opInfo = OpCode.getInfo(opCode);
    
    var opeland = _fetchOpeland(opInfo.mode);
    _execute(opInfo.op, opInfo.mode, opeland);

    var debugTypeStr = opInfo.op.toString().split(".").last;
    var debugModeStr = opInfo.mode.toString().split(".").last;
    // if (opeland != null) {
    //   print("0x${debugCurrentPC.toRadixString(16).padLeft(4, '0')}, $debugTypeStr ($debugModeStr) : 0x${opeland.toRadixString(16).padLeft(4, '0')}");
    // } else {
    //   print("0x${debugCurrentPC.toRadixString(16).padLeft(4, '0')}, $debugTypeStr ($debugModeStr) : null");
    // }

    // サイクル数を返す
    return 1;
  }

  int _fetchPC() {
    return mem.read(registers.pc++);
  }

  int _fetchOpeland(OpAddressingMode mode) {
    switch(mode) {
      case OpAddressingMode.Implied:
      case OpAddressingMode.Accumulator:
        return null;

      case OpAddressingMode.Immediate:
        // 次の番地の値をそのままデータとして使う
        return _fetchPC();

      case OpAddressingMode.Relative:
        // PCの値と次の番地の値を加算した値を演算対象にする
        // 符号拡張で計算する。オフセットは -128 ~ +127を指定可能
        var address = _fetchPC();
        return address < 128 ? registers.pc + address : registers.pc + address - 256;
      
      case OpAddressingMode.ZeroPage:
      case OpAddressingMode.ZeroPageX:
      case OpAddressingMode.ZeroPageY:
      case OpAddressingMode.IndexedIndirect:
      case OpAddressingMode.IndirctIndexed:
        break;
      
      case OpAddressingMode.Absolute:
        // 次の値を下位アドレス、その次の値を上位アドレスとした番地を演算対象にする
        var low = _fetchPC();
        var high = _fetchPC();
        return high << 8 | low;
      
      case OpAddressingMode.AbsolutePageX:
        // 次の値を下位アドレス、その次の値を上位アドレスとした番地にXインデックスレジスタを加算した値を演算対象にする
        var low = _fetchPC();
        var high = _fetchPC();
        return (high << 8 | low) + registers.x; // & 0xFFFFが必要説? オーバフローを落とす的な感じだろうか?
      
      case OpAddressingMode.AbsolutePageY:
      case OpAddressingMode.AbsoluteIndirect:
        break;
    }
    throw new EmulatorNotImplementedError("AddressingMode: $mode");
  }

  void _execute(OpType type, OpAddressingMode mode, int opeland) {
    switch(type) {
      case OpType.BNE:
        if (!registers.sZero) {
          registers.pc = opeland;
        }
        break;

      case OpType.DEY:
        registers.y--;
        registers.sZero = (registers.y == 0);
        registers.sNegative = (registers.y << 7 & 1 == 1);
        break;

      case OpType.INX:
        registers.x++;
        registers.sZero = (registers.x == 0);
        registers.sNegative = (registers.x << 7 & 1 == 1);
        break;

      case OpType.JMP:
        registers.pc = opeland;
        break;

      case OpType.LDA:
        registers.a = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a << 7 & 1 == 1);
        break;

      case OpType.LDX:
        registers.x = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.sZero = (registers.x == 0);
        registers.sNegative = (registers.x << 7 & 1 == 1);
        break;

      case OpType.LDY:
        registers.y = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.sZero = (registers.y == 0);
        registers.sNegative = (registers.y << 7 & 1 == 1);
        break;

      case OpType.SEI:
        registers.sInterupt = true;
        break;

      case OpType.STA:
        mem.write(opeland, registers.a);
        break;

      case OpType.TXS:
        registers.sp = registers.x;
        break;

      default:
        throw new EmulatorNotImplementedError("Execute op: $type");
    }
  }

  // RESET割り込み
  void _interuptReset() {
    registers.sInterupt = true;
    var pcLowByte = mem.read(0xfffc);
    var pcHighByte = mem.read(0xfffd);
    registers.pc = pcHighByte << 8 | pcLowByte;
  }
}

