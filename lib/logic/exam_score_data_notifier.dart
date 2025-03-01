import 'dart:async';
import 'dart:io';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';

class ExamScoreDataNotifier extends StateNotifier<ExamScoreDataState> {
  late FirebaseFirestore db;
  final Ref _ref;
  StreamSubscription<QuerySnapshot>? listener;
  ExamScoreDataNotifier(this._ref)
      : super(ExamScoreDataState(
            examId: '', ownerUserId: '', score: '', readOnly: true, loading: false)) {
    db = FirebaseFirestore.instance;
  }

  Future<void> getScoreData(String examId, String ownerUserId, bool readOnly) async {
    final userClassCode = _ref.read(authProvider).classCode;
    final userId = _ref.read(authProvider).user?.uid;
    state = ExamScoreDataState(
        examId: examId, ownerUserId: ownerUserId, score: '', readOnly: true, loading: true);
    try {
      final dataRef =
          db.collection('class/$userClassCode/exam/${state.examId}/submitted').doc(userId);
      final dataSnap = await dataRef.get();
      if (!dataSnap.exists) {
        state = ExamScoreDataState(
            examId: examId,
            ownerUserId: ownerUserId,
            score: '',
            readOnly: readOnly,
            loading: false);
      } else {
        final folder = await getApplicationDocumentsDirectory();
        state = ExamScoreDataState(
            examId: examId,
            ownerUserId: ownerUserId,
            score: dataSnap.data()?['score']?.toString() ?? '',
            readOnly: true,
            loading: false,
            submittedTime: dataSnap.data()?['timestamp'].toDate());
        Future.delayed(Duration(milliseconds: 100)).then((_) {
          state = state.copy(updateImage: true, imagePath: '${folder.path}/${state.examId}.jpg');
        });
      }
    } catch (e) {
      _showError(e.toString());
      state = ExamScoreDataState(
          examId: examId, ownerUserId: ownerUserId, score: '', readOnly: true, loading: false);
    }
  }

  void editScore(String score) {
    state = state.copy(score: score);
  }

  void editImage(String path) {
    state = state.copy(imagePath: path, updateImage: true);
  }

  bool precheck() {
    if (state.score == '') {
      toastification.show(
        type: ToastificationType.info,
        style: ToastificationStyle.flatColored,
        title: const Text('未填寫成績'),
        description: const Text('請輸入正確成績。'),
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: false,
      );
      return false;
    }
    if (int.tryParse(state.score) == null) {
      toastification.show(
        type: ToastificationType.info,
        style: ToastificationStyle.flatColored,
        title: const Text('成績內容有誤'),
        description: const Text('請輸入正確成績。'),
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: false,
      );
      return false;
    }
    if (int.parse(state.score) > 100 || int.parse(state.score) < 0) {
      toastification.show(
        type: ToastificationType.info,
        style: ToastificationStyle.flatColored,
        title: const Text('成績內容有誤'),
        description: const Text('請輸入正確成績。'),
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: false,
      );
      return false;
    }
    if (state.imagePath == null) {
      toastification.show(
        type: ToastificationType.info,
        style: ToastificationStyle.flatColored,
        title: const Text('尚未掃描考卷'),
        description: const Text('請先掃描考卷後。'),
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: false,
      );
      return false;
    }
    return true;
  }

  Future<bool> submitScore() async {
    final userClassCode = _ref.read(authProvider).classCode;
    final userId = _ref.read(authProvider).user?.uid;
    final userNumber = _ref.read(selfNumberProvider);
    state = state.copy(loading: true);
    try {
      await db.collection('class/$userClassCode/exam/${state.examId}/submitted').doc(userId).set({
        'student': userNumber,
        'score': int.parse(state.score),
        'timestamp': FieldValue.serverTimestamp(),
      });
      final storage = FirebaseStorage.instance;
      final ref = storage.ref('class/$userClassCode/${state.examId}/$userId/exampape.jpg');
      await ref.putFile(
          File(state.imagePath!),
          SettableMetadata(
            contentType: "image/jpeg",
            customMetadata: {'reader': state.ownerUserId},
          ));
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        title: const Text('提交成功'),
        description: const Text('您的分數已成功送出'),
        autoCloseDuration: const Duration(seconds: 5),
        showProgressBar: false,
      );
      state = state.copy(loading: false);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      _showError(e.toString());
      state = state.copy(loading: false);
      return false;
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

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }
}

class ExamScoreDataState {
  String examId;
  String ownerUserId;
  String score;
  String? imagePath;
  bool readOnly;
  bool loading;
  DateTime? submittedTime;

  ExamScoreDataState(
      {required this.examId,
      required this.ownerUserId,
      required this.score,
      this.imagePath,
      required this.readOnly,
      required this.loading,
      this.submittedTime});

  ExamScoreDataState copy({
    String? examId,
    String? ownerUserId,
    String? score,
    bool updateImage = false,
    String? imagePath,
    bool? readOnly,
    bool? loading,
  }) {
    return ExamScoreDataState(
      examId: examId ?? this.examId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      score: score ?? this.score,
      imagePath: updateImage ? imagePath : this.imagePath,
      readOnly: readOnly ?? this.readOnly,
      loading: loading ?? this.loading,
    );
  }
}
