import 'package:class_todo_list/error_handler.dart';
import 'package:class_todo_list/logic/task_notifier.dart';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFormNotifier extends StateNotifier<TaskFormState> {
  final Ref _ref;
  TaskFormNotifier(this._ref) : super(TaskFormState(name: '', date: DateTime.now()));

  void nameChange(String name) => state = state.copy(name: name);
  void typeChange(int type) => state = state.copy(type: type);
  void dateChange(DateTime date) => state = state.copy(date: date);
  void timeChange(TimeOfDay time) =>
      state = state.copy(date: state.date.copyWith(hour: time.hour, minute: time.minute));
  void editFinish() => state = state.copy(name: '', type: -1, formStatus: TaskFormStatus.create);

  void startUpdate(Task task) => state = state.copy(
        name: task.name,
        type: task.type,
        date: task.date,
        formStatus: TaskFormStatus.update,
        taskId: task.taskId,
      );

  Future<void> create() async {
    final userClassCode = _ref.read(authProvider).classCode;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DateTime now = DateTime.now();
    final data = {
      "name": state.name,
      "type": state.type,
      "date": state.date.subtract(Duration(hours: 8)).add(now.timeZoneOffset),
      "userId": _ref.read(authProvider).user?.uid,
      "top": false,
      "submitted": [],
      "lastUpdate": FieldValue.serverTimestamp(),
    };
    try {
      await db.collection("class/$userClassCode/task").add(data);
    } on FirebaseException catch (e) {
      ErrorHelper.handleFirebaseError(e);
    } catch (e) {
      ErrorHelper.handleError(e);
    }
    editFinish();
  }

  Future<void> update() async {
    final userClassCode = _ref.read(authProvider).classCode;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DateTime now = DateTime.now();
    final data = {
      "name": state.name,
      "type": state.type,
      "date": state.date.subtract(Duration(hours: 8)).add(now.timeZoneOffset),
      if (state.type != 4) 'submitted': [],
      "lastUpdate": FieldValue.serverTimestamp(),
      "lastUpdateUserId": _ref.read(authProvider).user?.uid,
    };
    try {
      await db.collection("class/$userClassCode/task").doc(state.taskId).update(data);
    } on FirebaseException catch (e) {
      ErrorHelper.handleFirebaseError(e);
    } catch (e) {
      ErrorHelper.handleError(e);
    }
    editFinish();
  }

  Future<void> remove() async {
    final userClassCode = _ref.read(authProvider).classCode;
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      await db.collection("class/$userClassCode/task").doc(state.taskId).delete();
    } on FirebaseException catch (e) {
      ErrorHelper.handleFirebaseError(e);
    } catch (e) {
      ErrorHelper.handleError(e);
    }
    editFinish();
  }
}

enum TaskFormStatus { create, update }

class TaskFormState {
  TaskFormState(
      {required this.name,
      this.type = -1,
      required this.date,
      this.formStatus = TaskFormStatus.create,
      this.taskId});
  final String name;
  final int type;
  final DateTime date;
  final TaskFormStatus formStatus;
  final String? taskId;
  TaskFormState copy(
          {String? name, int? type, DateTime? date, TaskFormStatus? formStatus, String? taskId}) =>
      TaskFormState(
        name: name ?? this.name,
        type: type ?? this.type,
        date: date ?? this.date,
        formStatus: formStatus ?? this.formStatus,
        taskId: taskId ?? this.taskId,
      );
}
