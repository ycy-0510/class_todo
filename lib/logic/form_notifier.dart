import 'package:class_todo_list/logic/task_notifier.dart';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaskFormNotifier extends StateNotifier<TaskFormState> {
  final Ref _ref;
  TaskFormNotifier(this._ref)
      : super(TaskFormState(name: '', date: DateTime.now()));

  void nameChange(String name) => state = state.copy(name: name);
  void typeChange(int type) => state = state.copy(type: type);
  void dateChange(DateTime date) => state = state.copy(date: date);
  void timeChange(TimeOfDay time) => state = state.copy(
      date: state.date.copyWith(hour: time.hour, minute: time.minute));
  void editFinish() =>
      state = state.copy(name: '', type: 0, formStatus: TaskFormStatus.create);

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

    final data = {
      "name": state.name,
      "type": state.type,
      "date": state.date,
      "userId": _ref.read(authProvider).user?.uid,
      "top": false,
      "submitted": [],
    };
    try {
      await db.collection("class/$userClassCode/task").add(data);
    } catch (e) {
      _showError(e.toString());
    }
    editFinish();
  }

  Future<void> update() async {
    final userClassCode = _ref.read(authProvider).classCode;
    FirebaseFirestore db = FirebaseFirestore.instance;

    final data = {
      "name": state.name,
      "type": state.type,
      "date": state.date,
      if (state.type != 4) 'submitted': [],
    };
    try {
      await db
          .collection("class/$userClassCode/task")
          .doc(state.taskId)
          .update(data);
    } catch (e) {
      _showError(e.toString());
    }
    editFinish();
  }

  Future<void> remove() async {
    final userClassCode = _ref.read(authProvider).classCode;
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      await db
          .collection("class/$userClassCode/task")
          .doc(state.taskId)
          .delete();
    } catch (e) {
      _showError(e.toString());
    }
    editFinish();
  }

  void _showError(String error) {
    Fluttertoast.showToast(
      msg: error,
      timeInSecForIosWeb: 1,
      webShowClose: true,
    );
  }
}

enum TaskFormStatus { create, update }

class TaskFormState {
  TaskFormState(
      {required this.name,
      this.type = 0,
      required this.date,
      this.formStatus = TaskFormStatus.create,
      this.taskId});
  final String name;
  final int type;
  final DateTime date;
  final TaskFormStatus formStatus;
  final String? taskId;
  TaskFormState copy(
          {String? name,
          int? type,
          DateTime? date,
          TaskFormStatus? formStatus,
          String? taskId}) =>
      TaskFormState(
        name: name ?? this.name,
        type: type ?? this.type,
        date: date ?? this.date,
        formStatus: formStatus ?? this.formStatus,
        taskId: taskId ?? this.taskId,
      );
}
