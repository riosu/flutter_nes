
class EmulatorMessageByParent {
  EmulatorMessageByParentType type;
  dynamic data;

  EmulatorMessageByParent(this.type, this.data);
}

class EmulatorMessageByChild {
  EmulatorMessageByChildType type;
  dynamic data;

  EmulatorMessageByChild(this.type, this.data);
}

enum EmulatorMessageByParentType {
  START,
  SET_DEBUG_CPU_LOG,
}

enum EmulatorMessageByChildType {
  INITIALIZE,
  UPDATE_FRAME,
}
