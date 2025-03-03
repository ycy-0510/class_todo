import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:class_todo_list/error_handler.dart';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class ExamScoreReviewNotifier extends StateNotifier<ExamScoreReviewState> {
  late FirebaseFirestore db;
  final Ref _ref;
  StreamSubscription<QuerySnapshot>? listener;
  ExamScoreReviewNotifier(this._ref)
      : super(ExamScoreReviewState(examId: '', toReview: [], reviewed: [], loading: true)) {
    db = FirebaseFirestore.instance;
  }

  Future<void> getScoreData(String examId) async {
    final userClassCode = _ref.read(authProvider).classCode;
    state = ExamScoreReviewState(examId: examId, toReview: [], reviewed: [], loading: true);
    try {
      final dataRef =
          await db.collection('class/$userClassCode/exam/${state.examId}/submitted').get();
      List<ScoreDataReview> toReview = [];
      for (final doc in dataRef.docs) {
        final data = doc.data();
        toReview.add(ScoreDataReview(doc.id, data['student'], data['score'], false));
      }
      for (int i = 1; i <= min(toReview.length, 2); i++) {
        toReview[toReview.length - i].image = await _getImage(toReview[toReview.length - i].userId);
      }
      state = state.copy(toReview: toReview, loading: false);
    } on FirebaseException catch (e) {
      ErrorHelper.handleFirebaseError(e);
      state = ExamScoreReviewState(examId: '', toReview: [], reviewed: [], loading: false);
    } catch (e) {
      ErrorHelper.handleError(e);
      state = ExamScoreReviewState(examId: '', toReview: [], reviewed: [], loading: false);
    }
  }

  Future<File> _getImage(String userId) async {
    final userClassCode = _ref.read(authProvider).classCode;
    final storage = FirebaseStorage.instance;
    final ref = storage.ref('class/$userClassCode/${state.examId}/$userId/exampape.jpg');
    final url = await ref.getDownloadURL();
    return await DefaultCacheManager().getSingleFile(url);
  }

  void review(bool accept) {
    final toReview = state.toReview;
    final reviewed = state.reviewed;
    final scoreData = toReview.removeLast();
    scoreData.accept = accept;
    reviewed.add(scoreData);
    state = state.copy(toReview: toReview, reviewed: reviewed);
    if (toReview.length >= 2) {
      _getImage(toReview[toReview.length - 2].userId).then((File file) {
        toReview[toReview.length - 2].image = file;
        state = state.copy(toReview: toReview);
      });
    }
  }

  Future<File?> getResult() async {
    if (state.toReview.isNotEmpty) {
      return null;
    }
    List<List<dynamic>> listData = [
      ['座號', '成績']
    ];
    List<ScoreDataReview> scoreDatas = state.reviewed;
    for (var data in scoreDatas) {
      listData.add([data.student, data.accept ? data.score : '-']);
    }
    Excel excel = Excel.createExcel();
    excel.rename('Sheet1', '分數');
    Sheet sheet = excel['分數'];
    sheet.appendRow([TextCellValue('學生'), TextCellValue('分數')]);
    for (var data in scoreDatas) {
      sheet.appendRow([
        TextCellValue(data.student),
        if (data.accept) IntCellValue(data.score) else TextCellValue('-')
      ]);
    }
    var fileBytes = excel.save();
    String dir = (await getApplicationCacheDirectory()).path;
    if (fileBytes == null) {
      ErrorHelper.handleError('匯出檔案發生錯誤');
      return null;
    }
    File xslxFile = File('$dir/exam_score_${state.examId}.xlsx');
    xslxFile.createSync(recursive: true);
    await xslxFile.writeAsBytes(fileBytes);
    return xslxFile;
  }

  Future<void> done() async {
    final userClassCode = _ref.read(authProvider).classCode;
    state = state.copy(loading: true);
    try {
      await db.collection('class/$userClassCode/exam').doc(state.examId).update({
        'done': true,
      });
      state = state.copy(loading: false);
    } on FirebaseException catch (e) {
      ErrorHelper.handleFirebaseError(e);
      state = state.copy(loading: false);
    } catch (e) {
      ErrorHelper.handleError(e);
      state = state.copy(loading: false);
    }
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }
}

class ExamScoreReviewState {
  String examId;
  List<ScoreDataReview> toReview;
  List<ScoreDataReview> reviewed;
  bool loading;

  ExamScoreReviewState(
      {required this.examId,
      required this.toReview,
      required this.reviewed,
      required this.loading});

  ExamScoreReviewState copy({
    String? examId,
    List<ScoreDataReview>? toReview,
    List<ScoreDataReview>? reviewed,
    bool? loading,
  }) {
    return ExamScoreReviewState(
      examId: examId ?? this.examId,
      toReview: toReview ?? this.toReview,
      reviewed: reviewed ?? this.reviewed,
      loading: loading ?? this.loading,
    );
  }
}

class ScoreDataReview {
  String userId;
  String student;
  int score;
  File? image;
  bool accept;
  ScoreDataReview(this.userId, this.student, this.score, this.accept, {this.image});
}
