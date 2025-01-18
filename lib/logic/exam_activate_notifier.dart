import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class ExamActivateNotifier extends StateNotifier<bool> {
  late FirebaseFirestore db;
  final Ref _ref;
  ExamActivateNotifier(this._ref) : super(false) {
    db = FirebaseFirestore.instance;
    getExamConfig();
  }

  void getExamConfig() async {
    final userClassCode = _ref.read(authProvider).classCode;
    state = false;
    if (!_ref.read(authProvider).user!.isAnonymous) {
      final dataRef = db.collection("class/$userClassCode/config").doc('exam');
      try {
        final examConfigData = await dataRef.get();
        if (examConfigData.exists &&
            examConfigData.data()?['activated'] is bool) {
          state = examConfigData.data()?['activated'];
        }
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String error) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: const Text("發生錯誤"),
      description: Text(error),
      alignment: Alignment.topCenter,
      showProgressBar: false,
      autoCloseDuration: const Duration(milliseconds: 1500),
    );
  }
}
