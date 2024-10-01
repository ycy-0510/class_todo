import 'dart:convert';

import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class ClassTableNotifier extends StateNotifier<ClassTableState> {
  static String tableKey = 'classTable';
  static String timeKey = 'classTime';
  static String classTableUpdateKey = 'classTableUpdate';
  late FirebaseFirestore db;
  final Ref _ref;
  ClassTableNotifier(this._ref)
      : super(ClassTableState(List.generate(54, (idx) => '課程'),
            List.generate(9, (idx) => TimeOfDay(hour: idx, minute: 0)))) {
    db = FirebaseFirestore.instance;
    autoUpdate();
  }

  void autoUpdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(tableKey) == null || prefs.getString(timeKey) == null) {
      updateClassTable();
    } else {
      getClassTable();
    }
  }

  void updateClassTable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userClassCode = _ref.read(authProvider).classCode;
    bool success = true;
    final dataRef =
        db.collection("class/$userClassCode/config").doc('classTable');
    try {
      final usersData = await dataRef.get();
      if (usersData.exists && usersData.data()?['table'] is List) {
        final originList = (usersData.data()?['table'] as List)
            .map((e) => e.toString())
            .toList();
        if (originList.length == 9 * 6) {
          prefs.setString(tableKey, jsonEncode(originList));
        } else {
          success = false;
          _showError('更新課表失敗');
        }
      } else {
        success = false;
        _showError('更新課表失敗');
      }

      if (usersData.exists && usersData.data()?['time'] is List) {
        final originList = (usersData.data()?['time'] as List)
            .map((e) => DateTime.parse(e.toDate().toString()))
            .toList();
        final timeList =
            originList.map((dateTime) => dateTime.toIso8601String()).toList();
        if (timeList.length == 9 + 1) {
          prefs.setString(timeKey, jsonEncode(timeList));
        } else {
          success = false;
          _showError('更新課表時間失敗');
        }
      } else {
        success = false;
        _showError('更新課表時間失敗');
      }
    } catch (e) {
      success = false;
      _showError(e.toString());
    }
    if (success) {
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        title: const Text("更新課表成功"),
        alignment: Alignment.topCenter,
        showProgressBar: false,
        autoCloseDuration: const Duration(milliseconds: 1500),
      );
      prefs.setString(classTableUpdateKey, DateTime.now().toIso8601String());
    }
    getClassTable();
  }

  void clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(tableKey);
    prefs.remove(timeKey);
    prefs.remove(classTableUpdateKey);
  }

  void getClassTable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(tableKey) != null && prefs.getString(timeKey) != null) {
      try {
        final tableList =
            (jsonDecode(prefs.getString(tableKey) ?? "[]") as List)
                .map((e) => e.toString())
                .toList();
        state = state.copy(table: tableList);
      } catch (e) {
        _showError(e.toString());
        return;
      }

      try {
        final timeOriginList =
            (jsonDecode(prefs.getString(timeKey) ?? "[]") as List)
                .map((e) => e.toString())
                .toList();
        final timeList = timeOriginList
            .map((dateString) =>
                TimeOfDay.fromDateTime(DateTime.parse(dateString)))
            .toList();
        state = state.copy(time: timeList);
      } catch (e) {
        _showError(e.toString());
        return;
      }
      try {
        state = state.copy(
            lastUpdate: DateTime.parse(prefs.getString(classTableUpdateKey)!));
      } catch (e) {
        _showError(e.toString());
        return;
      }

      state = state.copy(loading: false);
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

class ClassTableState {
  bool loading;
  late DateTime lastUpdate;
  List<String> table;
  List<TimeOfDay> time;
  ClassTableState(this.table, this.time, {this.loading = true}) {
    lastUpdate = DateTime(1900);
  }
  ClassTableState copy(
          {List<String>? table,
          List<TimeOfDay>? time,
          bool? loading,
          DateTime? lastUpdate}) =>
      ClassTableState(table ?? this.table, time ?? this.time,
          loading: loading ?? true)
        ..lastUpdate = lastUpdate ?? this.lastUpdate;
}
