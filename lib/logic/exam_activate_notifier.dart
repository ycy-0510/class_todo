import 'package:class_todo_list/error_handler.dart';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        if (examConfigData.exists && examConfigData.data()?['activated'] is bool) {
          state = examConfigData.data()?['activated'];
        }
      } on FirebaseException catch (e) {
        ErrorHelper.handleFirebaseError(e);
      } catch (e) {
        ErrorHelper.handleError(e);
      }
    }
  }
}
