
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
}

enum EmulatorMessageByChildType {
  INITIALIZE,
  UPDATE_FRAME,
}
