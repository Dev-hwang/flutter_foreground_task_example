import 'package:flutter/widgets.dart';

class BaseController {
  State? _state;

  State? get state => _state;

  void runIfStateIsAttached(void Function(State state) func) {
    final State? currentState = state;
    if (currentState != null) {
      func(currentState);
    }
  }

  @mustCallSuper
  void attach(State state) {
    _state = state;
  }

  @mustCallSuper
  void detach() {
    _state = null;
  }

  @mustCallSuper
  void dispose() {
    detach();
  }
}
