import 'package:class_todo_list/error_handler.dart';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final dataRef = db.collection("class/$userClassCode/config").doc('student');
      try {
        final usersData = await dataRef.get();
        Map<String, String> usersMap = {};
        if (usersData.exists && usersData.data()?['students'] is Map) {
          final originMap = usersData.data()?['students'] as Map<String, dynamic>;
          final keys = originMap.keys.toList()..sort((a, b) => int.parse(a) - int.parse(b));
          for (var key in keys) {
            usersMap.addAll({key: originMap[key].toString()});
          }
        } else {
          ErrorHelper.handleError('找不到學生資料');
        }
        state = usersMap;
      } on FirebaseException catch (e) {
        ErrorHelper.handleFirebaseError(e);
      } catch (e) {
        ErrorHelper.handleError(e);
      }
    }
  }
}
