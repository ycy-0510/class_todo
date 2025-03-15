import 'dart:async';
import 'dart:io';
import 'package:class_todo_list/error_handler.dart';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    } on FirebaseException catch (e) {
      ErrorHelper.handleFirebaseError(e);
    } catch (e) {
      ErrorHelper.handleError(e);
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
        alignment: Alignment.topCenter,
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
        alignment: Alignment.topCenter,
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
        alignment: Alignment.topCenter,
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
        alignment: Alignment.topCenter,
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
    state = state.updateProgress(0);
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref('class/$userClassCode/${state.examId}/$userId/exampape.jpg');
      final uploadTask = ref.putFile(
          File(state.imagePath!),
          SettableMetadata(
            contentType: "image/jpeg",
            customMetadata: {'reader': state.ownerUserId},
          ));
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
        switch (taskSnapshot.state) {
          case TaskState.running:
            state = state.updateProgress(taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            break;
          default:
            break;
        }
      });
      if ((await uploadTask).state == TaskState.success) {
        await db.collection('class/$userClassCode/exam/${state.examId}/submitted').doc(userId).set({
          'student': userNumber,
          'score': int.parse(state.score),
          'timestamp': FieldValue.serverTimestamp(),
        });
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: const Text('提交成功'),
          description: const Text('您的分數已成功送出'),
          autoCloseDuration: const Duration(seconds: 5),
          alignment: Alignment.topCenter,
          showProgressBar: false,
        );
        state = state.copy(loading: false);
        return true;
      } else {
        state = state.copy(loading: false);
        return false;
      }
    } on FirebaseException catch (e) {
      state = state.copy(loading: false);
      ErrorHelper.handleFirebaseError(e);
      return false;
    } catch (e) {
      ErrorHelper.handleError(e);
      state = state.copy(loading: false);
      return false;
    }
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
  double? uploadProgress;
  DateTime? submittedTime;

  ExamScoreDataState({
    required this.examId,
    required this.ownerUserId,
    required this.score,
    this.imagePath,
    required this.readOnly,
    required this.loading,
    this.submittedTime,
    this.uploadProgress,
  });

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

  ExamScoreDataState updateProgress(double? progress) {
    return ExamScoreDataState(
      examId: examId,
      ownerUserId: ownerUserId,
      score: score,
      imagePath: imagePath,
      readOnly: readOnly,
      loading: true,
      uploadProgress: progress,
    );
  }
}
