import 'package:class_todo_list/error_handler.dart';
import 'package:class_todo_list/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BetaNotifier extends StateNotifier<bool> {
  final betaKey = 'beta';
  int timesToEnable = 55;
  static const _defaultValue = false;
  final Ref _ref;
  BetaNotifier(this._ref) : super(_defaultValue) {
    _init();
  }

  SharedPreferences get _sharedPreferences => _ref.read(sharedPreferencesProvider).requireValue;

  Future<void> _init() async {
    state = _sharedPreferences.getBool(betaKey) ?? _defaultValue;
  }

  void setBeta(bool beta) {
    state = beta;
    _sharedPreferences.setBool(betaKey, beta);
  }

  void increaseCounter(int x) {
    timesToEnable -= x;
    if (timesToEnable == 0 &&
        _ref.read(authProvider).user?.providerData.first.providerId !=
            AppleAuthProvider.PROVIDER_ID) {
      ErrorHelper.handleWarning('已啟用增強功能');
      setBeta(true);
    }
  }
}
