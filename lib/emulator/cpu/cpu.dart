
import 'dart:typed_data';

import 'package:flutter_nes/emulator/cpu/cpu_memory.dart';
import 'package:flutter_nes/emulator/cpu/cpu_registers.dart';
import 'package:flutter_nes/emulator/cpu/opcode.dart';
import 'package:flutter_nes/emulator/emulator.dart';
import 'package:flutter_nes/emulator/errors.dart';
import 'package:flutter_nes/utils/logger.dart';

class Cpu {
  final Emulator emulator;

  CpuRegisters registers;
  CpuMemory mem;

  int debugCPUCount = 0;

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

    // _debugPrint(debugCurrentPC, opCode, opeland);
    _execute(opInfo.op, opInfo.mode, opeland);

    return opInfo.cycle;
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
        // 上位アドレスを$00、下位アドレスとして読みだした値を演算対象にする
        return _fetchPC();

      case OpAddressingMode.ZeroPageX:
        // 上位アドレスを$00、下位アドレスとして読みだした値にXインデックスレジスタを加算した値を演算対象にする
        return (_fetchPC() + registers.x) & 0xFF;

      case OpAddressingMode.ZeroPageY:
        // 上位アドレスを$00、下位アドレスとして読みだした値にYインデックスレジスタを加算した値を演算対象にする
        return (_fetchPC() + registers.y) & 0xFF;

      case OpAddressingMode.IndexedIndirect:
        // 上位アドレスを$00、下位アドレスを読みだした値にXレジスタを加算した(8)値を下位アドレスとする
        // そのアドレスに格納されている値を、演算対象の下位バイト、その次のアドレスの値を演算対象の上位バイトとする
        var address = (_fetchPC() + registers.x) & 0xFF;
        var low = mem.read(address);
        var high = mem.read((address + 1) & 0xFF);
        return high << 8 | low;

      case OpAddressingMode.IndirctIndexed:
        // 上位アドレスを$00、下位アドレスとして読みだした値を利用する
        // そのアドレスに格納されている値を、上位バイト、その次のアドレスの値を下位アドレスにし、
        // そこにYレジスタを加算(16)したものを演算対象とする
        var address = _fetchPC();
        var low = mem.read(address);
        var high = mem.read((address + 1) & 0xFF);
        return ((high << 8 | low) + registers.y) & 0xFFFF;
      
      case OpAddressingMode.Absolute:
        // 次の値を下位アドレス、その次の値を上位アドレスとした番地を演算対象にする
        var low = _fetchPC();
        var high = _fetchPC();
        return high << 8 | low;
      
      case OpAddressingMode.AbsolutePageX:
        // 次の値を下位アドレス、その次の値を上位アドレスとした番地にXインデックスレジスタを加算した値を演算対象にする
        var low = _fetchPC();
        var high = _fetchPC();
        return ((high << 8 | low) + registers.x) & 0xFFFF;
      
      case OpAddressingMode.AbsolutePageY:
        // 次の値を下位アドレス、その次の値を上位アドレスとした番地にYインデックスレジスタを加算した値を演算対象にする
        var low = _fetchPC();
        var high = _fetchPC();
        return ((high << 8 | low) + registers.y) & 0xFFFF;

      case OpAddressingMode.AbsoluteIndirect:
        // 次の値を下位アドレス、その次の値を上位アドレスとした番地に格納されている値を演算対象の上位バイト、
        // その次のアドレスの値を演算対象の下位バイトとする。下位アドレスのキャリーは無視する
        var baseLow = _fetchPC();
        var baseHigh = _fetchPC();
        var low = mem.read(baseHigh << 8 | baseLow);
        var high = mem.read((baseHigh << 8 | ((baseLow + 1) & 0xFF)) & 0xFFFF);
        return high << 8 | low;
    }

    throw new EmulatorNotImplementedError("AddressingMode: $mode");
  }

  void _execute(OpType type, OpAddressingMode mode, int opeland) {
    switch(type) {
      // 演算
      case OpType.ADC:
        var data = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        var calculated = registers.a + data + ((registers.sCarry) ? 1 : 0);
        registers.sCarry = (calculated >> 8 & 1 == 1);
        registers.sOverflow = (((registers.a ^ data) >> 7 & 1 == 0) && (registers.a ^ calculated) >> 7 & 1 == 1);
        registers.a = calculated & 0xFF;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.SBC:
        var data = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        var calculated = registers.a - data - ((registers.sCarry) ? 0 : 1);
        registers.sCarry = (calculated >= 0);
        registers.sOverflow = (((registers.a ^ data) >> 7 & 1 == 1) && (registers.a ^ calculated) >> 7 & 1 == 1);
        registers.a = calculated & 0xFF;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      // 論理演算
      case OpType.AND:
        var data = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.a = registers.a & data;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.ORA:
        var data = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.a = registers.a | data;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.EOR:
        var data = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.a = registers.a ^ data;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      // シフト・ローテーション
      case OpType.ASL:
        var data = (mode == OpAddressingMode.Accumulator) ? registers.a : mem.read(opeland);
        var calculated = (data << 1) & 0xFF;

        registers.sCarry = (data >> 7 & 1 == 1);
        registers.sZero = (calculated == 0);
        registers.sNegative = (calculated >> 7 & 1 == 1);

        if (mode == OpAddressingMode.Accumulator) {
          registers.a = calculated;
        } else {
          mem.write(opeland, calculated);
        }
        break;

      case OpType.LSR:
        var data = (mode == OpAddressingMode.Accumulator) ? registers.a : mem.read(opeland);
        var calculated = (data >> 1) & 0xFF;

        registers.sCarry = (data & 1 == 1);
        registers.sZero = (calculated == 0);
        registers.sNegative = (calculated >> 7 & 1 == 1);

        if (mode == OpAddressingMode.Accumulator) {
          registers.a = calculated;
        } else {
          mem.write(opeland, calculated);
        }
        break;

      case OpType.ROL:
        var data = (mode == OpAddressingMode.Accumulator) ? registers.a : mem.read(opeland);
        var calculated = (data << 1 | ((registers.sCarry) ? 1 : 0)) & 0xFF;

        registers.sCarry = (data >> 7 & 1 == 1);
        registers.sZero = (calculated == 0);
        registers.sNegative = (calculated >> 7 & 1 == 1);

        if (mode == OpAddressingMode.Accumulator) {
          registers.a = calculated;
        } else {
          mem.write(opeland, calculated);
        }
        break;

      case OpType.ROR:
        var data = (mode == OpAddressingMode.Accumulator) ? registers.a : mem.read(opeland);
        var calculated = (data >> 1 | ((registers.sCarry) ? 0x80 : 0)) & 0xFF;

        registers.sCarry = (data & 1 == 1);
        registers.sZero = (calculated == 0);
        registers.sNegative = (calculated >> 7 & 1 == 1);

        if (mode == OpAddressingMode.Accumulator) {
          registers.a = calculated;
        } else {
          mem.write(opeland, calculated);
        }
        break;

      // 条件分岐
      case OpType.BCC:
        if (!registers.sCarry) {
          registers.pc = opeland;
        }
        break;
        
      case OpType.BCS:
        if (registers.sCarry) {
          registers.pc = opeland;
        }
        break;
        
      case OpType.BEQ:
        if (registers.sZero) {
          registers.pc = opeland;
        }
        break;
        
      case OpType.BNE:
        if (!registers.sZero) {
          registers.pc = opeland;
        }
        break;
        
      case OpType.BVC:
        if (!registers.sOverflow) {
          registers.pc = opeland;
        }
        break;
        
      case OpType.BVS:
        if (registers.sOverflow) {
          registers.pc = opeland;
        }
        break;
        
      case OpType.BPL:
        if (!registers.sNegative) {
          registers.pc = opeland;
        }
        break;
        
      case OpType.BMI:
        if (registers.sNegative) {
          registers.pc = opeland;
        }
        break;

      // BIT検査
      case OpType.BIT:
        var data = mem.read(opeland);
        registers.sZero = registers.a & data == 0;
        registers.sNegative = (data >> 7 & 1 == 1);
        registers.sOverflow = (data >> 6 & 1 == 1);
        break;

      // ジャンプ
      case OpType.JMP:
        registers.pc = opeland;
        break;

      case OpType.JSR:
        var returnAddress = registers.pc - 1;
        _stackPush(returnAddress >> 8);
        _stackPush(returnAddress & 0xFF);
        registers.pc = opeland;
        break;

      case OpType.RTI:
        var p = _stackPop();
        registers.sNegative = (p >> 7 & 1 == 1);
        registers.sOverflow = (p >> 6 & 1 == 1);
        registers.sDecimal = (p >> 3 & 1 == 1);
        registers.sInterupt = (p >> 2 & 1 == 1);
        registers.sZero = (p >> 1 & 1 == 1);
        registers.sCarry = (p & 1 == 1);
        var low = _stackPop();
        var high = _stackPop();
        registers.pc = high << 8 | low;
        break;

      case OpType.RTS:
        var low = _stackPop();
        var high = _stackPop();
        registers.pc = (high << 8 | low) + 1;
        break;

      // 割り込み

      // 比較
      case OpType.CMP:
        var data = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        var res = registers.a - data;
        registers.sCarry = (res >= 0) ? true : false;
        registers.sZero = (res == 0);
        registers.sNegative = (res >> 7 & 1 == 1);
        break;

      case OpType.CPX:
        var data = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        var res = registers.x - data;
        registers.sCarry = (res >= 0) ? true : false;
        registers.sZero = (res == 0);
        registers.sNegative = (res >> 7 & 1 == 1);
        break;

      case OpType.CPY:
        var data = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        var res = registers.y - data;
        registers.sCarry = (res >= 0) ? true : false;
        registers.sZero = (res == 0);
        registers.sNegative = (res >> 7 & 1 == 1);
        break;

      // インクリメント・デクリメント
      case OpType.INC:
        var res = (mem.read(opeland) + 1) & 0xFF;
        mem.write(opeland, res);
        registers.sZero = (res == 0);
        registers.sNegative = (res >> 7 & 1 == 1);
        break;

      case OpType.DEC:
        var res = (mem.read(opeland) - 1) & 0xFF;
        mem.write(opeland, res);
        registers.sZero = (res == 0);
        registers.sNegative = (res >> 7 & 1 == 1);
        break;
        
      case OpType.INX:
        registers.x = ++registers.x & 0xFF;
        registers.sZero = (registers.x == 0);
        registers.sNegative = (registers.x >> 7 & 1 == 1);
        break;
        
      case OpType.DEX:
        registers.x = --registers.x & 0xFF;
        registers.sZero = (registers.x == 0);
        registers.sNegative = (registers.x >> 7 & 1 == 1);
        break;
        
      case OpType.INY:
        registers.y = ++registers.y & 0xFF;
        registers.sZero = (registers.y == 0);
        registers.sNegative = (registers.y >> 7 & 1 == 1);
        break;

      case OpType.DEY:
        registers.y = --registers.y & 0xFF;
        registers.sZero = (registers.y == 0);
        registers.sNegative = (registers.y >> 7 & 1 == 1);
        break;

      // フラグ操作
      case OpType.CLC:
        registers.sCarry = false;
        break;

      case OpType.CLI:
        registers.sInterupt = false;
        break;

      case OpType.CLD:
        registers.sDecimal = false;
        break;

      case OpType.CLV:
        registers.sOverflow = false;
        break;

      case OpType.SEC:
        registers.sCarry = true;
        break;

      case OpType.SEI:
        registers.sInterupt = true;
        break;

      case OpType.SED:
        registers.sDecimal  =true;
        break;

      // ロード
      case OpType.LDA:
        registers.a = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.LDX:
        registers.x = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.sZero = (registers.x == 0);
        registers.sNegative = (registers.x >> 7 & 1 == 1);
        break;

      case OpType.LDY:
        registers.y = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.sZero = (registers.y == 0);
        registers.sNegative = (registers.y >> 7 & 1 == 1);
        break;

      // ストア
      case OpType.STA:
        mem.write(opeland, registers.a);
        break;

      case OpType.STX:
        mem.write(opeland, registers.x);
        break;

      case OpType.STY:
        mem.write(opeland, registers.y);
        break;

      // レジスタ間転送
      case OpType.TAX:
        registers.x = registers.a;
        registers.sZero = (registers.x == 0);
        registers.sNegative = (registers.x >> 7 & 1 == 1);
        break;

      case OpType.TXA:
        registers.a = registers.x;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.TAY:
        registers.y = registers.a;
        registers.sZero = (registers.y == 0);
        registers.sNegative = (registers.y >> 7 & 1 == 1);
        break;

      case OpType.TYA:
        registers.a = registers.y;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.TSX:
        registers.x = registers.sp;
        registers.sZero = (registers.x == 0);
        registers.sNegative = (registers.x >> 7 & 1 == 1);
        break;

      case OpType.TXS:
        registers.sp = registers.x;
        break;

      // スタック
      case OpType.PHA:
        _stackPush(registers.a);
        break;

      case OpType.PLA:
        registers.a = _stackPop();
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.PHP:
        // PHPコマンドでスタックに入れるデータはBreakフラグが立っている
        _stackPush(registers.p | 0x10);
        break;

      case OpType.PLP:
        var p = _stackPop();
        registers.sNegative = (p >> 7 & 1 == 1);
        registers.sOverflow = (p >> 6 & 1 == 1);
        registers.sDecimal = (p >> 3 & 1 == 1);
        registers.sInterupt = (p >> 2 & 1 == 1);
        registers.sZero = (p >> 1 & 1 == 1);
        registers.sCarry = (p & 1 == 1);
        break;

      // No operation
      case OpType.NOP:
        break;

      // Unofficial opecodes
      case OpType.LAX:
        registers.a = (mode == OpAddressingMode.Immediate) ? opeland : mem.read(opeland);
        registers.x = registers.a;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.SAX:
        mem.write(opeland, registers.a & registers.x);
        break;

      case OpType.DCP:
        var data = (mem.read(opeland) - 1) & 0xFF;
        mem.write(opeland, data);
        
        var res = registers.a - data;
        registers.sCarry = (res >= 0) ? true : false;
        registers.sZero = (res == 0);
        registers.sNegative = (res >> 7 & 1 == 1);
        break;

      case OpType.ISB:
        var data = (mem.read(opeland) + 1) & 0xFF;
        mem.write(opeland, data);

        var calculated = registers.a - data - ((registers.sCarry) ? 0 : 1);
        registers.sCarry = (calculated >= 0);
        registers.sOverflow = (((registers.a ^ data) >> 7 & 1 == 1) && (registers.a ^ calculated) >> 7 & 1 == 1);
        registers.a = calculated & 0xFF;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.SLO:
        var data = mem.read(opeland);
        var calculated = (data << 1) & 0xFF;
        registers.sCarry = (data >> 7 & 1 == 1);

        mem.write(opeland, calculated);
        registers.a = registers.a | calculated;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.RLA:
        var data = mem.read(opeland);
        var calculated = (data << 1 | ((registers.sCarry) ? 1 : 0)) & 0xFF;
        registers.sCarry = (data >> 7 & 1 == 1);

        mem.write(opeland, calculated);
        registers.a = registers.a & calculated;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.SRE:
        var data = mem.read(opeland);
        var calculated = (data >> 1) & 0xFF;
        registers.sCarry = (data & 1 == 1);

        mem.write(opeland, calculated);
        registers.a = registers.a ^ calculated;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      case OpType.RRA:
        var data = mem.read(opeland);
        var calculated1 = (data >> 1 | ((registers.sCarry) ? 0x80 : 0)) & 0xFF;
        mem.write(opeland, calculated1);
        registers.sCarry = (data & 1 == 1);

        var calculated2 = registers.a + calculated1 + ((registers.sCarry) ? 1 : 0);
        registers.sCarry = (calculated2 >> 8 & 1 == 1);
        registers.sOverflow = (((registers.a ^ calculated1) >> 7 & 1 == 0) && (registers.a ^ calculated2) >> 7 & 1 == 1);
        registers.a = calculated2 & 0xFF;
        registers.sZero = (registers.a == 0);
        registers.sNegative = (registers.a >> 7 & 1 == 1);
        break;

      default:
        throw new EmulatorNotImplementedError("Execute op: $type ($debugCPUCount)");
    }
   
  }

  // RESET割り込み
  void _interuptReset() {
    registers.sInterupt = true;
    var pcLowByte = mem.read(0xfffc);
    var pcHighByte = mem.read(0xfffd);
    registers.pc = pcHighByte << 8 | pcLowByte;

    // for nestest.nes
    // registers.pc = 0xC000;
  }

  void _stackPush(int data) {
    var address = 0x01 << 8 | registers.sp;
    mem.write(address, data);
    registers.sp--;
  }

  int _stackPop() {
    registers.sp++;
    var address = 0x01 << 8 | registers.sp;
    return mem.read(address);
  }

  void _debugPrint(int pc, int opCode, int opeland) {
    var op = OpCode.getInfo(opCode);

    var opelandRaws = List<int>();
    for(var i = 1; i <= registers.pc - pc - 1; i++) {
      opelandRaws.add(mem.read(pc + i));
    }
    var rawCode = "";
    rawCode += pc.toRadixString(16).padLeft(4, '0').toUpperCase() + "  ";
    rawCode += opCode.toRadixString(16).padLeft(2, '0').toUpperCase();
    for(var raw in opelandRaws) {
      rawCode += " " + raw.toRadixString(16).padLeft(2, '0').toUpperCase();
    }

    var typeStr = op.op.toString().split(".").last.toUpperCase();
    var opStr = typeStr + " ";
    switch(op.mode) {
      case OpAddressingMode.Implied:
        break;

      case OpAddressingMode.Accumulator:
        opStr += "A";
        break;

      case OpAddressingMode.Immediate:
        opStr += "#\$" + opelandRaws[0].toRadixString(16).padLeft(2, "0").toUpperCase();
        break; 

      case OpAddressingMode.ZeroPage:
        opStr += "\$";
        opStr += opeland.toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += " = " + mem.read(opelandRaws[0]).toRadixString(16).padLeft(2, "0").toUpperCase();
        break;

      case OpAddressingMode.ZeroPageX:
        opStr += "\$";
        opStr += opelandRaws[0].toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += ",X @ " + opeland.toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += " = " + mem.read(opeland).toRadixString(16).padLeft(2, "0").toUpperCase();
        break;

      case OpAddressingMode.ZeroPageY:
        opStr += "\$";
        opStr += opelandRaws[0].toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += ",Y @ " + opeland.toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += " = " + mem.read(opeland).toRadixString(16).padLeft(2, "0").toUpperCase();
        break;

      case OpAddressingMode.IndexedIndirect:
        var address = (opelandRaws[0] + registers.x) & 0xFF;
        var high = mem.read((address + 1) & 0xFF);
        var low = mem.read(address);
        var data = mem.read(high << 8 | low);
        opStr += "(\$${opelandRaws[0].toRadixString(16).padLeft(2, "0").toUpperCase()},X)";
        opStr += " @ ${address.toRadixString(16).padLeft(2, "0").toUpperCase()}";
        opStr += " = ${high.toRadixString(16).padLeft(2, "0").toUpperCase()}";
        opStr += "${low.toRadixString(16).padLeft(2, "0").toUpperCase()}";
        opStr += " = ${data.toRadixString(16).padLeft(2, "0").toUpperCase()}";
        break;

      case OpAddressingMode.IndirctIndexed:
        var address = opelandRaws[0];
        var high = mem.read((address + 1) & 0xFF);
        var low = mem.read(address);
        var targetAddress = ((high << 8 | low) + registers.y) & 0xFFFF;
        var data = mem.read(targetAddress);
        opStr += "(\$${opelandRaws[0].toRadixString(16).padLeft(2, "0").toUpperCase()}),Y";
        opStr += " = ${high.toRadixString(16).padLeft(2, "0").toUpperCase()}";
        opStr += "${low.toRadixString(16).padLeft(2, "0").toUpperCase()}";
        opStr += " @ ${targetAddress.toRadixString(16).padLeft(4, "0").toUpperCase()}";
        opStr += " = ${data.toRadixString(16).padLeft(2, "0").toUpperCase()}";
        break;

      case OpAddressingMode.Relative:
        opStr += "\$";
        opStr += opeland.toRadixString(16).padLeft(4, "0").toUpperCase();
        break;
  
      case OpAddressingMode.Absolute:
        opStr += "\$";
        opStr += opeland.toRadixString(16).padLeft(4, "0").toUpperCase();

        const ignoreTypes = [OpType.JMP, OpType.JSR];
        if (!ignoreTypes.contains(op.op)) {
          opStr += " = " + mem.read(opeland).toRadixString(16).padLeft(2, "0").toUpperCase();
        }
        break;
      case OpAddressingMode.AbsolutePageX:
        opStr += "\$";
        opStr += opelandRaws[1].toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += opelandRaws[0].toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += ",X @ ";
        opStr += opeland.toRadixString(16).padLeft(4, "0").toUpperCase();
        opStr += " = " + mem.read(opeland).toRadixString(16).padLeft(2, "0").toUpperCase();
        break;

      case OpAddressingMode.AbsolutePageY:
        opStr += "\$";
        opStr += opelandRaws[1].toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += opelandRaws[0].toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += ",Y @ ";
        opStr += opeland.toRadixString(16).padLeft(4, "0").toUpperCase();
        opStr += " = " + mem.read(opeland).toRadixString(16).padLeft(2, "0").toUpperCase();
        break;

      case OpAddressingMode.AbsoluteIndirect:
        var baseLow = opelandRaws[0];
        var baseHigh = opelandRaws[1];
        var low = mem.read(baseHigh << 8 | baseLow);
        var high = mem.read(((baseHigh << 8 | baseLow) + 1) & 0xFFFF);

        opStr += "(\$" + baseHigh.toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += baseLow.toRadixString(16).padLeft(2, "0").toUpperCase() + ")";
        opStr += " = " + high.toRadixString(16).padLeft(2, "0").toUpperCase();
        opStr += low.toRadixString(16).padLeft(2, "0").toUpperCase();
        break;

      default:
        opStr += op.mode.toString().split(".").last;
        break;
    }

    var currentStatus = "";
    currentStatus += "A:" + registers.a.toRadixString(16).padLeft(2, "0").toUpperCase();
    currentStatus += " X:" + registers.x.toRadixString(16).padLeft(2, "0").toUpperCase();
    currentStatus += " Y:" + registers.y.toRadixString(16).padLeft(2, "0").toUpperCase();
    currentStatus += " P:" + registers.p.toRadixString(16).padLeft(2, "0").toUpperCase();
    currentStatus += " SP:" + registers.sp.toRadixString(16).padLeft(2, "0").toUpperCase();
    currentStatus += " CYC:" + emulator.ppu.cycle.toString().padLeft(3, " ");
    currentStatus += " SL:" + emulator.ppu.line.toString().padLeft(3, " ");

    var test = rawCode.padRight(16, " ") + opStr.padRight(32, " ") + currentStatus;
    // var expect = emulator.debugCPULogs[debugCPUCount].substring(0, 74).replaceAll("*", " ");
    // if (expect != test.substring(0, 74)) {
    //   Logger.debug("----------------------------------------------------------");
    //   Logger.debug("!!! CPUDebugLogDifferentError !!!");
    //   Logger.debug("----------------------------------------------------------");
    //   for(int i = debugCPUCount - 5; i < debugCPUCount; i++) {
    //     if (i < 0) continue;
    //     Logger.debug(emulator.debugCPULogs[i].substring(0, 74));
    //   }
    //   Logger.debug("----------------------------------------------------------");

    //   Logger.debug("[expect] ${emulator.debugCPULogs[debugCPUCount].substring(0, 74)}");
    //   Logger.debug("[actual] ${test.substring(0, 74)}");

    //   var expectP = int.parse(emulator.debugCPULogs[debugCPUCount].substring(65, 67), radix: 16);
    //   var actualP = int.parse(test.substring(65, 67), radix: 16);
    //   if (expectP != actualP) {
    //     Logger.debug("P = [expect] ${expectP.toRadixString(2).padLeft(8, "0")} != ${actualP.toRadixString(2).padLeft(8, "0")} [actual]");
    //   }

    //   Logger.debug(op.mode.toString().split(".").last);

    //   throw CPUDebugLogDifferentError(debugCPUCount);
    // }
    // debugCPUCount++;

    Logger.debug(test);
  }

}

