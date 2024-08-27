import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateNotifier extends StateNotifier<DateState> {
  DateNotifier()
      : super(DateState(
          now: DateTime.now(),
          week: 0,
          thisWeek: DateTime.now(),
        )) {
    int year = state.now.year;
    int month = state.now.month;
    int day = state.now.day - (state.now.weekday) % 7;
    state = state.copy(
      thisWeek: DateTime(year, month, day),
    );
    Timer.periodic(const Duration(minutes: 2), (timer) {
      DateTime now = DateTime.now();
      if (!(now.year == state.now.year &&
          now.month == state.now.month &&
          now.day == state.now.day)) {
        state = state.copy(now: now);
      }
    });
  }

  void go(int week) {
    state = state.copy(
      week: week - 1000,
    );
  }
}

class DateState {
  DateState({required this.now, required this.week, required this.thisWeek});
  final DateTime now;
  final int week;
  final DateTime thisWeek;

  DateState copy({DateTime? now, int? week, DateTime? thisWeek}) => DateState(
        now: now ?? this.now,
        week: week ?? this.week,
        thisWeek: thisWeek ?? this.thisWeek,
      );
}
