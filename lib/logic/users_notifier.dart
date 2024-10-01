import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class UsersNotifier extends StateNotifier<Map<String, String>> {
  late FirebaseFirestore db;
  final Ref _ref;
  UsersNotifier(this._ref) : super({}) {
    db = FirebaseFirestore.instance;
    getUserData();
  }

  void getUserData() async {
    final userClassCode = _ref.read(authProvider).classCode;
    state = {};
    if (!_ref.read(authProvider).user!.isAnonymous) {
      final dataRef =
          db.collection("user").where('class', isEqualTo: userClassCode);
      try {
        final usersData = await dataRef.get();
        Map<String, String> usersMap = {};
        for (var user in usersData.docs) {
          usersMap[user.id] = user.data()['name'];
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
