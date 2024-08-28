import 'dart:async';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AnnounceNotifier extends StateNotifier<List> {
  late FirebaseFirestore db;
  final Ref _ref;
  StreamSubscription<QuerySnapshot>? listener;
  AnnounceNotifier(this._ref) : super([]) {
    db = FirebaseFirestore.instance;
  }

  void sendData(String text) async {
    // if (text.isNotEmpty) {
    //   try {
    //     DocumentReference dataRef = await db.collection('announce').add({
    //       'content': text,
    //       'userId': _ref.read(authProvider).user!.uid,
    //       'date': FieldValue.serverTimestamp()
    //     });
    //     const String gasUrl =
    //         'https://script.google.com/macros/s/AKfycbxVtO1mvVZMtu8QZBg2OjcZWfE4kNcAQlaC_UtY0QNwwwsMlJMcODrESWIeXkP1-QEuOQ/exec';
    //     var res = await http
    //         .get(Uri.parse('$gasUrl?announceId=${dataRef.id}&code=yccjyt'));
    //     if (res.statusCode != 200 || res.body != '200') {
    //       _showError('傳送Line錯誤');
    //     }
    //   } catch (e) {
    //     _showError(e.toString());
    //   }
    // }
  }

  void _showError(String error) {
    Fluttertoast.showToast(
      msg: error,
      timeInSecForIosWeb: 2,
      webShowClose: true,
    );
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }
}
