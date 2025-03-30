import 'package:class_todo_list/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelfNumberNotifier extends StateNotifier<String> {
  static String key = 'selfNumber';
  final Ref _ref;
  SelfNumberNotifier(this._ref) : super('') {
    getNumber();
  }

  SharedPreferences get _sharedPreferences => _ref.read(sharedPreferencesProvider).requireValue;

  Future<void> getNumber() async {
    state = _sharedPreferences.getString(key) ?? '';
  }

  Future<void> setNumber(String number) async {
    _sharedPreferences.setString(key, number);
    state = number;
  }
}
