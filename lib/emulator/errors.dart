
class EmulatorNotImplementedError extends Error {
  final String msg;

  EmulatorNotImplementedError(this.msg);

  String toString() => "EmulatorNotImplementedError: $msg";
}

class UnknownOpCodeError extends Error {
  final int opCode;

  UnknownOpCodeError(this.opCode);

  String toString() => "UnknownOpCodeError: opCode = 0x${opCode.toRadixString(16).padLeft(2, '0')}";
}

enum MemoryAccessType {
  CPU,
  PPU,
}

class MemoryAccessError extends Error {
  final MemoryAccessType type;
  final int address;

  MemoryAccessError(this.type, this.address);

  String toString() => "MemoryAccessError: $type, 0x${address.toRadixString(16).padLeft(4, '0')}";
}

class MemoryAccessNotImplementedError extends Error {
  final MemoryAccessType type;
  final int address;

  MemoryAccessNotImplementedError(this.type, this.address);

  String toString() => "MemoryAccessNotImplementedError: $type, 0x${address.toRadixString(16).padLeft(4, '0')}";
}
