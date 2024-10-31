import 'dart:io';

import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

enum NotificationAuthorizationStatus {
  authorized,
  appDenied,
  systemDenied,
  notDetermined
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  static String notificationKey = 'notification';
  late FirebaseFirestore db;
  late FirebaseMessaging messaging;
  final Ref _ref;
  NotificationNotifier(this._ref)
      : super(NotificationState(
            NotificationAuthorizationStatus.notDetermined, '', false)) {
    db = FirebaseFirestore.instance;
    messaging = FirebaseMessaging.instance;
    init();
  }

  void init() async {
    NotificationSettings settings = await messaging.getNotificationSettings();
    state = NotificationState(
        NotificationAuthorizationStatus.notDetermined, '', false);
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        String? token = await messaging.getToken();
        state = state.copy(
            openBottomSheet: false,
            authorizationStatus: NotificationAuthorizationStatus.authorized,
            fcmToken: token);
        final user = _ref.read(authProvider).user;
        if (token != null) {
          if (!kDebugMode) {
            await db.collection("user/${user!.uid}/private").doc('fcm').update({
              "tokens": FieldValue.arrayUnion([token]),
            });
          }
        }
        getNotificationTime();
        break;
      case AuthorizationStatus.denied:
        if (Platform.isAndroid) {
          state = state.copy(
            openBottomSheet: false,
            authorizationStatus: NotificationAuthorizationStatus.appDenied,
          );
        } else {
          state = state.copy(
            openBottomSheet: false,
            authorizationStatus: NotificationAuthorizationStatus.systemDenied,
          );
        }
        break;
      default:
        break;
    }
    _updateLocalStatusData();
  }

  void openBottomSheet() {
    init();
    if (state.authorizationStatus !=
        NotificationAuthorizationStatus.systemDenied) {
      state = state.copy(openBottomSheet: true);
    }
  }

  void closeBottomSheet() {
    state = state.copy(
      openBottomSheet: false,
      authorizationStatus: NotificationAuthorizationStatus.appDenied,
    );
    _updateLocalStatusData();
  }

  Future<void> requestPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          String? token = await messaging.getToken();
          state = state.copy(
              openBottomSheet: false,
              authorizationStatus: NotificationAuthorizationStatus.authorized,
              fcmToken: token);
          final user = _ref.read(authProvider).user;
          if (token != null) {
            if (!kDebugMode) {
              await db
                  .collection("user/${user!.uid}/private")
                  .doc('fcm')
                  .update({
                "tokens": FieldValue.arrayUnion([token]),
              });
            }
            toastification.show(
              type: ToastificationType.success,
              style: ToastificationStyle.flatColored,
              title: const Text("您的通知已啟用！"),
              description: const Text('你可以在「更多>個人設定」中設定通知時間。'),
              alignment: Alignment.topCenter,
              showProgressBar: false,
              autoCloseDuration: const Duration(milliseconds: 1500),
            );
          }
          getNotificationTime();
          break;
        case AuthorizationStatus.denied:
          if (Platform.isAndroid) {
            state = state.copy(
              openBottomSheet: false,
              authorizationStatus: NotificationAuthorizationStatus.appDenied,
            );
          } else {
            state = state.copy(
              openBottomSheet: false,
              authorizationStatus: NotificationAuthorizationStatus.systemDenied,
            );
          }
          _showError('若要接收通知請至「系統設定」開啟。');
          break;
        default:
          break;
      }
    } catch (e) {
      _showError(e.toString());
    }
    _updateLocalStatusData();
  }

  void _updateLocalStatusData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (state.authorizationStatus) {
      case NotificationAuthorizationStatus.authorized:
        prefs.setString(notificationKey, 'authorized');
        break;
      case NotificationAuthorizationStatus.appDenied:
        prefs.setString(notificationKey, 'appDenied');
        break;
      case NotificationAuthorizationStatus.systemDenied:
        prefs.setString(notificationKey, 'systemDenied');
        break;
      case NotificationAuthorizationStatus.notDetermined:
        prefs.remove(notificationKey);
        break;
    }
  }

  void clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(notificationKey) == 'appDenied') {
      prefs.remove(notificationKey);
    }
    final user = _ref.read(authProvider).user;
    try {
      _ref.read(classTableProvider.notifier).clear();
      _ref.read(classTableProvider.notifier).dispose();
      await db.collection("user/${user!.uid}/private").doc('fcm').update({
        "tokens": FieldValue.arrayRemove([state.fcmToken]),
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> getNotificationTime() async {
    final user = _ref.read(authProvider).user;
    final userData = await db.collection("user").doc(user!.uid).get();
    if (userData.exists && userData.data()?['notificationTime'] is Timestamp) {
      state = state.copy(
          copyNotificationTime: false,
          notificationTime: userData.data()?['notificationTime'].toDate());
    }
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    DateTime dateTime = DateTime(2024);
    if (time.minute % 30 != 0) {
      if ((time.minute - 30).abs() < 15) {
        dateTime = DateTime(2024, 1, 1, time.hour, 30);
      } else {
        dateTime = (time.minute < 30
            ? DateTime(2024, 1, 1, time.hour, 0)
            : DateTime(2024, 1, 1, (time.hour + 1) % 24, 0));
      }
      toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.flatColored,
        title: Text("已調整通知時間為${DateFormat('HH:mm').format(dateTime)}"),
        description: const Text("目前通知只能設為整點或30分。"),
        alignment: Alignment.topCenter,
        showProgressBar: false,
        autoCloseDuration: const Duration(milliseconds: 2000),
      );
    } else {
      dateTime = DateTime(2024, 1, 1, time.hour, time.minute);
    }
    final user = _ref.read(authProvider).user;
    state = state.copy(copyNotificationTime: false, notificationTime: dateTime);
    try {
      await db
          .collection("user")
          .doc(user!.uid)
          .update({"notificationTime": dateTime});
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        title: const Text("設定通知時間成功"),
        description: Text('已設定為${DateFormat('HH:mm').format(dateTime)}'),
        alignment: Alignment.topCenter,
        showProgressBar: false,
        autoCloseDuration: const Duration(milliseconds: 1500),
      );
    } catch (e) {
      _showError(e.toString());
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

class NotificationState {
  bool loading;
  NotificationAuthorizationStatus authorizationStatus;
  String fcmToken;
  DateTime? notificationTime;
  bool openBottomSheet;
  NotificationState(
      this.authorizationStatus, this.fcmToken, this.openBottomSheet,
      {this.notificationTime, this.loading = true});
  NotificationState copy({
    NotificationAuthorizationStatus? authorizationStatus,
    String? fcmToken,
    bool copyNotificationTime = true,
    DateTime? notificationTime,
    bool? openBottomSheet,
    bool? loading,
  }) =>
      NotificationState(authorizationStatus ?? this.authorizationStatus,
          fcmToken ?? this.fcmToken, openBottomSheet ?? this.openBottomSheet,
          notificationTime:
              copyNotificationTime ? this.notificationTime : notificationTime,
          loading: loading ?? true);
}
