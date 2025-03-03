import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart';
import 'package:logger/logger.dart';

class ErrorHelper {
  static void handleInfo(i) {
    final logger = Logger();
    toastification.show(
        type: ToastificationType.info,
        style: ToastificationStyle.flatColored,
        title: Text('提示'),
        description: Text('$i'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 2),
        borderRadius: BorderRadius.circular(12.0),
        dragToClose: true,
        showProgressBar: false);
    logger.i(i);
  }

  static void handleWarning(w) {
    final logger = Logger();
    toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.flatColored,
        title: Text('警告'),
        description: Text('$w'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(12.0),
        dragToClose: true,
        showProgressBar: false);
    logger.w(w);
  }

  static void handleError(e) {
    final logger = Logger();
    toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('發生錯誤'),
        description: Text('$e'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12.0),
        dragToClose: true,
        showProgressBar: false);
    logger.e(e);
  }

  static void handleFirebaseError(FirebaseException e) {
    final logger = Logger();
    toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('發生錯誤'),
        description: Text('${e.message}'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 2),
        borderRadius: BorderRadius.circular(12.0),
        dragToClose: true,
        showProgressBar: false);
    logger.e(e);
  }
}
