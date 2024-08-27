import 'dart:async';

import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

int toClassTime(DateTime dateTime, List<TimeOfDay> classTimes) {
  TimeOfDay time = TimeOfDay.fromDateTime(dateTime);
  for (int i = 0; i < classTimes.length - 1; i++) {
    if (classTimes[i].hour * 60 + classTimes[i].minute <=
            time.hour * 60 + time.minute &&
        classTimes[i + 1].hour * 60 + classTimes[i + 1].minute >
            time.hour * 60 + time.minute) {
      return i;
    }
  }
  return -1;
}

class TaskNotifier extends StateNotifier<TaskState> {
  late FirebaseFirestore db;
  final Ref _ref;
  Map<int, StreamSubscription<QuerySnapshot>> listeners = {};
  TaskNotifier(this._ref)
      : super(TaskState({-1: [], 0: [], 1: []}, loading: true)) {
    db = FirebaseFirestore.instance;
    getData(0, 0);
    _ref.listen(dateProvider, (previous, next) {
      getData(previous!.week, next.week);
    });
  }

  void getData(int prevWeek, int nextWeek) {
    final userClassCode = _ref.read(authProvider).classCode;
    if (nextWeek == prevWeek) {
      for (int i = nextWeek - 2; i <= nextWeek + 2; i++) {
        final dataRef = db
            .collection("class/$userClassCode/task")
            .where("date",
                isGreaterThanOrEqualTo:
                    _ref.read(dateProvider).thisWeek.add(Duration(days: 7 * i)))
            .where("date",
                isLessThanOrEqualTo: _ref
                    .read(dateProvider)
                    .thisWeek
                    .add(Duration(days: 7 * (i + 1))));
        listeners[i]?.cancel();
        listeners[i] = dataRef.snapshots().listen(
          (data) {
            List<Task> tasks = [];
            for (var docSnapshot in data.docs) {
              tasks.add(Task.fromFirestore(
                  docSnapshot, _ref.read(classTableProvider).time));
            }
            state.tasksMap[i] = tasks;
            state = state.copy();
          },
          onError: (e) => _showError(e.toString()),
        );
        if (i == 0) {
          state.loading = false;
          state = state.copy();
        }
      }
    } else if (nextWeek > prevWeek) {
      final dataRef = db
          .collection("class/$userClassCode/task")
          .where("date",
              isGreaterThanOrEqualTo: _ref
                  .read(dateProvider)
                  .thisWeek
                  .add(Duration(days: 7 * (nextWeek + 1))))
          .where("date",
              isLessThanOrEqualTo: _ref
                  .read(dateProvider)
                  .thisWeek
                  .add(Duration(days: 7 * (nextWeek + 2))));
      listeners[nextWeek - 2]?.cancel();
      listeners[nextWeek + 1] = dataRef.snapshots().listen(
        (data) {
          List<Task> tasks = [];
          for (var docSnapshot in data.docs) {
            tasks.add(Task.fromFirestore(
                docSnapshot, _ref.read(classTableProvider).time));
          }
          state.tasksMap[nextWeek + 1] = tasks;
          state.tasksMap.remove(nextWeek - 2);
          state = state.copy();
        },
        onError: (e) => _showError(e.toString()),
      );
    } else {
      final dataRef = db
          .collection("class/$userClassCode/task")
          .where("date",
              isGreaterThanOrEqualTo: _ref
                  .read(dateProvider)
                  .thisWeek
                  .add(Duration(days: 7 * (nextWeek - 1))))
          .where("date",
              isLessThanOrEqualTo: _ref
                  .read(dateProvider)
                  .thisWeek
                  .add(Duration(days: 7 * (nextWeek))));
      listeners[nextWeek + 2]?.cancel();
      listeners[nextWeek - 1] = dataRef.snapshots().listen(
        (data) {
          List<Task> tasks = [];
          for (var docSnapshot in data.docs) {
            tasks.add(Task.fromFirestore(
                docSnapshot, _ref.read(classTableProvider).time));
          }
          state.tasksMap[nextWeek - 1] = tasks;
          state.tasksMap.remove(nextWeek + 2);
          state = state.copy();
        },
        onError: (e) => _showError(e.toString()),
      );
    }
  }

  void _showError(String error) {
    Fluttertoast.showToast(
      msg: error,
      timeInSecForIosWeb: 1,
      webShowClose: true,
    );
  }

  @override
  void dispose() {
    print(listeners.length);
    for (MapEntry<int, StreamSubscription<QuerySnapshot>> entry
        in listeners.entries) {
      entry.value.cancel();
      listeners.remove(entry.key);
    }
    super.dispose();
  }
}

class TaskState {
  Map<int, List<Task>> tasksMap;
  bool loading;
  TaskState(this.tasksMap, {this.loading = false});
  TaskState copy() => TaskState(tasksMap, loading: loading);
}

class Task {
  String name;
  int type;
  DateTime date;
  int classTime;
  bool top;
  String userId;
  String taskId;
  Task({
    required this.name,
    required this.type,
    required this.date,
    required this.classTime,
    required this.top,
    required this.userId,
    required this.taskId,
  });

  factory Task.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    List<TimeOfDay> classTime, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    return Task(
      name: data?['name'],
      type: data?['type'],
      date: data?['date'].toDate(),
      classTime: toClassTime(data?['date'].toDate(), classTime),
      top: data?['top'],
      userId: data?['userId'],
      taskId: snapshot.id,
    );
  }

  void pinTop(WidgetRef ref) {
    final userClassCode = ref.read(authProvider).classCode;
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("class/$userClassCode/task").doc(taskId).update({
      'top': !top,
    });
  }
}
