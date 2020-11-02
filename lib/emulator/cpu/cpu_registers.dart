
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

  int sp = 0xFD; // Stack pointer
  int pc = 0x00; // Program counter

  int get p {
    return ((sNegative)  ? 1 << 7 : 0) | 
      ((sOverflow)  ? 1 << 6 : 0) | 
      ((sReserved)  ? 1 << 5 : 0) | 
      ((sBreak)     ? 1 << 4 : 0) | 
      ((sDecimal)   ? 1 << 3 : 0) | 
      ((sInterupt)  ? 1 << 2 : 0) | 
      ((sZero)      ? 1 << 1 : 0) |
      ((sCarry)     ? 1 : 0);
  }
}