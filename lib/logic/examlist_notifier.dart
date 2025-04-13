import 'dart:async';
import 'package:class_todo_list/error_handler.dart';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamlistNotifier extends StateNotifier<ExamlistState> {
  late FirebaseFirestore db;
  final Ref _ref;
  StreamSubscription<QuerySnapshot>? listener;
  ExamlistNotifier(this._ref) : super(ExamlistState([], loading: true)) {
    db = FirebaseFirestore.instance;
    getData();
    _ref.listen(dateProvider, (previous, next) {
      getData();
    });
    Timer.periodic(const Duration(seconds: 30), (timer) {
      for (ExamData examData in state.examItems) {
        if (examData.examStatus != ExamStatus.archived) {
          examData.updateStatus();
        }
      }
      state = state.copy();
    });
  }

  void getData() {
    final userClassCode = _ref.read(authProvider).classCode;
    state = ExamlistState([], loading: true);
    final dataRef = db
        .collection('class/$userClassCode/exam')
        .where("startTime",
            isGreaterThanOrEqualTo: _ref.read(dateProvider).now.subtract(const Duration(days: 30)))
        .orderBy('startTime', descending: true);
    listener?.cancel();
    listener = dataRef.snapshots().listen(
      (data) {
        List<ExamData> submittedItem = [];
        for (var docSnapshot in data.docs) {
          submittedItem.add(ExamData.fromFirestore(docSnapshot));
        }
        state = ExamlistState(submittedItem);
      },
      onError: (e) => ErrorHelper.handleError(e),
    );
  }

  Future<String?> newExam(String name) async {
    final userClassCode = _ref.read(authProvider).classCode;
    try {
      final docRef = await db.collection('class/$userClassCode/exam').add({
        'name': name,
        'startTime': FieldValue.serverTimestamp(),
        'userId': _ref.read(authProvider).user!.uid,
        'done': false,
      });
      return docRef.id;
    } on FirebaseException catch (e) {
      ErrorHelper.handleFirebaseError(e);
      return null;
    } catch (e) {
      ErrorHelper.handleError(e);
      return null;
    }
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }
}

class ExamlistState {
  List<ExamData> examItems;
  bool loading;
  ExamlistState(this.examItems, {this.loading = false});

  ExamlistState copy({bool loading = false}) => ExamlistState(examItems, loading: loading);
}

enum ExamStatus { ongoing, processing, done, archived }

class ExamData {
  String name;
  DateTime startTime;
  late DateTime endTime;
  String userId;
  String examId;
  late ExamStatus examStatus;
  bool done;

  ExamData({
    required this.name,
    required this.startTime,
    required this.userId,
    required this.examId,
    required this.done,
  }) {
    updateStatus();
  }

  void updateStatus() {
    bool isOngoing;
    DateTime now = DateTime.now();
    DateTime startTimeStd =
        startTime.add(Duration(hours: 8 - now.timeZoneOffset.inHours)); //Taipei Standard Time
    DateTime startTimeLimStd = startTimeStd
            .subtract(Duration(
                hours: startTimeStd.hour,
                minutes: startTimeStd.minute,
                seconds: startTimeStd.second,
                milliseconds: startTimeStd.millisecond))
            .add(Duration(hours: 8)), //Start time limit (08:00)
        endTimeLatStd = startTimeStd
            .subtract(Duration(
                hours: startTimeStd.hour,
                minutes: startTimeStd.minute,
                seconds: startTimeStd.second,
                milliseconds: startTimeStd.millisecond))
            .add(Duration(hours: 16)), //End Time at 16:00
        endTimeDurStd = startTimeStd.add(const Duration(hours: 3));
    DateTime startTimeLim =
            startTimeLimStd.subtract(Duration(hours: 8 - now.timeZoneOffset.inHours)),
        endTimeLat = endTimeLatStd.subtract(Duration(hours: 8 - now.timeZoneOffset.inHours)),
        endTimeDur = endTimeDurStd.subtract(Duration(hours: 8 - now.timeZoneOffset.inHours));
    if (endTimeLat.isBefore(endTimeDur) || startTime.isBefore(startTimeLim)) {
      isOngoing = now.isBefore(endTimeDur);
      endTime = endTimeDur;
    } else {
      isOngoing = now.isBefore(endTimeLat);
      endTime = endTimeLat;
    }
    if (isOngoing) {
      examStatus = ExamStatus.ongoing;
    } else if (DateTime.now().isBefore(startTime.add(const Duration(hours: 24))) && !done) {
      examStatus = ExamStatus.processing;
    } else if (done) {
      examStatus = ExamStatus.done;
    } else {
      examStatus = ExamStatus.archived;
    }
  }

  factory ExamData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    return ExamData(
      name: data?['name'],
      startTime: data?['startTime'].toDate(),
      userId: data?['userId'],
      examId: snapshot.id,
      done: data?['done'],
    );
  }
}
