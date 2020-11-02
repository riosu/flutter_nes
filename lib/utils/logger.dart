import 'dart:io';

class Logger {
  static void debug(String message) {
    stdout.writeln(message);
  }
}
