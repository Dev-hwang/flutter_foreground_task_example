import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/base_controller.dart';

mixin ErrorHandlerMixin on BaseController {
  void handleError(Object e, StackTrace s) {
    String errorMessage;
    if (e is PlatformException) {
      errorMessage = '${e.code}: ${e.message}';
    } else {
      errorMessage = e.toString();
    }

    // Print error to console.
    dev.log('$errorMessage\n${s.toString()}');

    // Show error to user.
    final State? state = this.state;
    if (state != null && state.mounted) {
      final SnackBar snackBar = SnackBar(content: Text(errorMessage));
      ScaffoldMessenger.of(state.context).showSnackBar(snackBar);
    }
  }
}
