
class CpuRegisters {
  int a = 0x00;  // Accumulator
  int x = 0x00;  // Index register
  int y = 0x00;  // Index register

  // Status register
  bool sNegative = false; // N
  bool sOverflow = false; // V
  bool sReserved = true;  // (always true)
  bool sBreak = false;    // B
  bool sDecimal = false;  // D
  bool sInterupt = false; // I
  bool sZero = false;     // Z
  bool sCarry = false;    // C

  int sp = 0x00; // Stack pointer
  int pc = 0x00; // Program counter
}