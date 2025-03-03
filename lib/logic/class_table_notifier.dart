import 'dart:convert';

import 'package:class_todo_list/error_handler.dart';
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

  SharedPreferences get _sharedPreferences => _ref.read(sharedPreferencesProvider).requireValue;

  void autoUpdate() async {
    if (_sharedPreferences.getString(tableKey) == null ||
        _sharedPreferences.getString(timeKey) == null) {
      updateClassTable();
    } else {
      getClassTable();
    }
  }

  void updateClassTable() async {
    final userClassCode = _ref.read(authProvider).classCode;
    bool success = true;
    final dataRef = db.collection("class/$userClassCode/config").doc('classTable');
    try {
      final usersData = await dataRef.get();
      if (usersData.exists && usersData.data()?['table'] is List) {
        final originList = (usersData.data()?['table'] as List).map((e) => e.toString()).toList();
        if (originList.length == 9 * 6) {
          _sharedPreferences.setString(tableKey, jsonEncode(originList));
        } else {
          success = false;
          ErrorHelper.handleError('更新課表失敗');
        }
      } else {
        success = false;
        ErrorHelper.handleError('更新課表失敗');
      }

      if (usersData.exists && usersData.data()?['time'] is List) {
        final originList = (usersData.data()?['time'] as List)
            .map((e) => DateTime.parse(e.toDate().toString()))
            .toList();
        final timeList = originList.map((dateTime) => dateTime.toIso8601String()).toList();
        if (timeList.length == 9 + 1) {
          _sharedPreferences.setString(timeKey, jsonEncode(timeList));
        } else {
          success = false;
          ErrorHelper.handleError('更新課表時間失敗');
        }
      } else {
        success = false;
        ErrorHelper.handleError('更新課表時間失敗');
      }
    } on FirebaseException catch (e) {
      ErrorHelper.handleFirebaseError(e);
    } catch (e) {
      success = false;
      ErrorHelper.handleError(e);
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
      _sharedPreferences.setString(classTableUpdateKey, DateTime.now().toIso8601String());
    }
    getClassTable();
  }

  void clear() async {
    _sharedPreferences.remove(tableKey);
    _sharedPreferences.remove(timeKey);
    _sharedPreferences.remove(classTableUpdateKey);
  }

  void getClassTable() async {
    if (_sharedPreferences.getString(tableKey) != null &&
        _sharedPreferences.getString(timeKey) != null) {
      try {
        final tableList = (jsonDecode(_sharedPreferences.getString(tableKey) ?? "[]") as List)
            .map((e) => e.toString())
            .toList();
        state = state.copy(table: tableList);
      } catch (e) {
        ErrorHelper.handleError(e);
        return;
      }

      try {
        final timeOriginList = (jsonDecode(_sharedPreferences.getString(timeKey) ?? "[]") as List)
            .map((e) => e.toString())
            .toList();
        final timeList = timeOriginList
            .map((dateString) => TimeOfDay.fromDateTime(DateTime.parse(dateString)))
            .toList();
        state = state.copy(time: timeList);
      } catch (e) {
        ErrorHelper.handleError(e);
        return;
      }
      try {
        state = state.copy(
            lastUpdate: DateTime.parse(_sharedPreferences.getString(classTableUpdateKey)!));
      } catch (e) {
        ErrorHelper.handleError(e);
        return;
      }

      state = state.copy(loading: false);
    }
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
          {List<String>? table, List<TimeOfDay>? time, bool? loading, DateTime? lastUpdate}) =>
      ClassTableState(table ?? this.table, time ?? this.time, loading: loading ?? true)
        ..lastUpdate = lastUpdate ?? this.lastUpdate;
}
