import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelfNumberNotifier extends StateNotifier<String> {
  static String key = 'selfNumber';
  SelfNumberNotifier() : super('') {
    getNumber();
  }

  Future<void> getNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    state = prefs.getString(key) ?? '';
  }

  Future<void> setNumber(String number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, number);
    state = number;
  }
}
