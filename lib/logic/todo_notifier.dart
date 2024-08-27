import 'dart:async';

import 'package:class_todo_list/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoNotifier extends StateNotifier<List<String>> {
  final Ref _ref;
  TodoNotifier(this._ref) : super([]) {
    getData();
    _ref.listen(dateProvider, (previous, next) {
      getData();
    });
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = _ref.read(dateProvider).thisWeek.toIso8601String();
    List<String> todos = prefs.getStringList(key) ?? [];
    state = todos;
  }

  Future<void> changeData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = _ref.read(dateProvider).thisWeek.toIso8601String();
    List<String> todos = List.generate(state.length, (index) => state[index]);
    if (todos.contains(id)) {
      todos.remove(id);
    } else {
      todos.add(id);
    }
    prefs.setStringList(key, todos);
    state = todos;
  }
}
