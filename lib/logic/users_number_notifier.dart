import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class UsersNumberNotifier extends StateNotifier<Map<String, String>> {
  late FirebaseFirestore db;
  final Ref _ref;
  UsersNumberNotifier(this._ref) : super({}) {
    db = FirebaseFirestore.instance;
    getUserData();
  }

  void getUserData() async {
    final userClassCode = _ref.read(authProvider).classCode;
    state = {};
    if (!_ref.read(authProvider).user!.isAnonymous) {
      final dataRef =
          db.collection("class/$userClassCode/config").doc('student');
      try {
        final usersData = await dataRef.get();
        Map<String, String> usersMap = {};
        if (usersData.exists && usersData.data()?['students'] is Map) {
          final originMap =
              usersData.data()?['students'] as Map<String, dynamic>;
          final keys = originMap.keys.toList()
            ..sort((a, b) => int.parse(a) - int.parse(b));
          for (var key in keys) {
            usersMap.addAll({key: originMap[key].toString()});
          }
        } else {
          _showError('Students not found');
        }
        state = usersMap;
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
