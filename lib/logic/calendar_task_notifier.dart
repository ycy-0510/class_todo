import 'dart:async';

import 'package:class_todo_list/error_handler.dart';
import 'package:class_todo_list/logic/google_api_notifier.dart';
import 'package:class_todo_list/logic/task_notifier.dart';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart';

class CalendarTaskNotifier extends StateNotifier<CalendarTaskState> {
  GoogleHttpClient? httpClient;
  List<String> calendarIds = [];
  final Ref _ref;
  Map<int, StreamSubscription<QuerySnapshot>> listeners = {};
  CalendarTaskNotifier(this._ref) : super(CalendarTaskState({}, loading: true)) {
    httpClient = _ref.read(googleApiProvider).googleHttpClient;
    if (httpClient != null) {
      getData(0, 0);
    }
    _ref.listen(dateProvider, (previous, next) {
      getData(previous!.week, next.week);
    });
    _ref.listen(googleApiProvider, (previous, next) async {
      httpClient = _ref.read(googleApiProvider).googleHttpClient;
      if (previous?.connected != next.connected || previous?.hasError != next.hasError) {
        calendarIds.clear();
        if (next.connected && next.googleHttpClient != null) {
          final calendarList = await CalendarApi(httpClient!).calendarList.list();
          for (final calendar in calendarList.items!) {
            if (!((calendar.id ?? '').endsWith('group.v.calendar.google.com'))) {
              calendarIds.add(calendar.id!);
            }
          }
        }
        getData(_ref.read(dateProvider).week, _ref.read(dateProvider).week);
      }
    });
  }

  Future<void> getData(int prevWeek, int nextWeek) async {
    if (nextWeek == prevWeek) {
      for (final k in [0, 1, -1, 2, -2, 3, -3]) {
        final i = k + nextWeek;
        Future.wait<Events>(calendarIds.map((id) => CalendarApi(httpClient!).events.list(
              id,
              timeMin: _ref.read(dateProvider).thisWeek.add(Duration(days: 7 * i)),
              timeMax: _ref.read(dateProvider).thisWeek.add(
                    Duration(days: 7 * (i + 1)),
                  ),
            ))).then((List<Events> listOfEventsList) {
          final events = listOfEventsList.fold<List<Event>>(<Event>[], (events, eventsList) {
            events.addAll(eventsList.items ?? []);
            return events;
          });
          List<CalendarTask> tasks = [];
          for (final event in events) {
            tasks.add(CalendarTask.fromCalendar(event, _ref.read(classTableProvider).time));
          }
          state.tasksMap[i] = tasks;
          state = state.copy();
        }).catchError((e) {
          ErrorHelper.handleError(e);
        });
        if (i == 0) {
          state.loading = false;
          state = state.copy();
        }
      }
    } else if (nextWeek > prevWeek) {
      Future.wait<Events>(calendarIds.map(
        (id) => CalendarApi(httpClient!).events.list(
              id,
              timeMin: _ref.read(dateProvider).thisWeek.add(Duration(days: 7 * (nextWeek + 2))),
              timeMax: _ref.read(dateProvider).thisWeek.add(Duration(days: 7 * (nextWeek + 3))),
            ),
      )).then((List<Events> eventsList) {
        final events = eventsList.fold<List<Event>>(<Event>[], (events, eventsList) {
          events.addAll(eventsList.items ?? []);
          return events;
        });
        List<CalendarTask> tasks = [];
        for (final event in events) {
          tasks.add(CalendarTask.fromCalendar(event, _ref.read(classTableProvider).time));
        }
        state.tasksMap[nextWeek + 2] = tasks;
        state.tasksMap.remove(nextWeek - 3);
        state = state.copy();
      }).catchError((e) {
        ErrorHelper.handleError(e);
      });
    } else {
      Future.wait<Events>(calendarIds.map((id) => CalendarApi(httpClient!).events.list(
            id,
            timeMin: _ref.read(dateProvider).thisWeek.add(Duration(days: 7 * (nextWeek - 2))),
            timeMax: _ref.read(dateProvider).thisWeek.add(Duration(days: 7 * (nextWeek - 1))),
          ))).then((List<Events> eventsList) {
        final events = eventsList.fold<List<Event>>(<Event>[], (events, eventsList) {
          events.addAll(eventsList.items ?? []);
          return events;
        });
        List<CalendarTask> tasks = [];
        for (final event in events) {
          tasks.add(CalendarTask.fromCalendar(event, _ref.read(classTableProvider).time));
        }
        state.tasksMap[nextWeek - 2] = tasks;
        state.tasksMap.remove(nextWeek + 3);
        state = state.copy();
      }).catchError((e) {
        ErrorHelper.handleError(e);
      });
    }
  }
}

class CalendarTaskState {
  Map<int, List<CalendarTask>> tasksMap;
  bool loading;
  CalendarTaskState(this.tasksMap, {this.loading = false});
  CalendarTaskState copy() => CalendarTaskState(tasksMap, loading: loading);
}

enum CalendarTaskType { classroom, personal }

class CalendarTask {
  String name;
  DateTime date;
  int classTime;
  String taskId;
  CalendarTaskType type;
  CalendarTask({
    required this.name,
    required this.date,
    required this.classTime,
    required this.taskId,
    required this.type,
  });

  factory CalendarTask.fromCalendar(
    Event event,
    List<TimeOfDay> classTime, [
    SnapshotOptions? options,
  ]) {
    return CalendarTask(
      name: event.summary ?? '',
      date: event.start!.dateTime?.add(const Duration(hours: 8)) ?? event.start!.date!,
      classTime: toClassTime(
          event.start!.dateTime?.add(const Duration(hours: 8)) ?? event.start!.date!, classTime),
      taskId: event.id ?? '',
      type: CalendarTaskType.personal,
    );
  }
}
