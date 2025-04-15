import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class NowTimeNotifier extends StateNotifier<DateTime> {
  NowTimeNotifier() : super(DateTime.now()) {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      state = DateTime.now().copyWith();
    });
  }
}

class TimeZoneNotifier extends StateNotifier<TimeZoneInfo> {
  TimeZoneNotifier()
      : super(TimeZoneInfo(DateTime.now().timeZoneOffset.inHours, DateTime.now().timeZoneName)) {
    Timer.periodic(const Duration(seconds: 20), (timer) {
      state = TimeZoneInfo(DateTime.now().timeZoneOffset.inHours, DateTime.now().timeZoneName);
    });
  }
}

class TimeZoneInfo {
  int tz;
  String name;
  TimeZoneInfo(this.tz, this.name);
}
