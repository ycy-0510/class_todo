import 'dart:convert';

import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  late FirebaseAuth _auth;
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState(init: false)) {
    _auth = FirebaseAuth.instance;
    if (_auth.currentUser != null) {
      _auth.currentUser!.reload();
    }

    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        state = AuthState();
      } else {
        FirebaseFirestore db = FirebaseFirestore.instance;
        final userData = await db.collection("user").doc(user.uid).get();
        if (userData.exists && userData.data()!['name'] is String) {
          state = AuthState(user: user, classCode: userData.data()?['class']);
        } else {
          state = AuthState(user: user);
          try {
            await db.collection("user").doc(user.uid).set({
              "name": user.displayName,
            });
          } catch (e) {
            _showError(e.toString());
          }
        }
        if (userData.data()?['notificationTime'] is! Timestamp) {
          await db
              .collection("user")
              .doc(user.uid)
              .update({"notificationTime": DateTime(2024, 1, 1, 20)});
        }
        final fcmData =
            await db.collection("user/${user.uid}/private").doc('fcm').get();
        if (!fcmData.exists || fcmData.data()?['tokens'] is! List) {
          await db
              .collection("user/${user.uid}/private")
              .doc('fcm')
              .set({"tokens": []});
        }
      }
    });
  }

  void googleLogin() async {
    if (!state.loggedIn) {
      state = state.load(true);
      try {
        if (kIsWeb) {
          GoogleAuthProvider googleProvider = GoogleAuthProvider();
          await _auth.signInWithPopup(googleProvider);
        } else {
          final GoogleSignInAccount? googleUser =
              await GoogleSignIn().signIn().catchError((onError) => null);
          final GoogleSignInAuthentication? googleAuth =
              await googleUser?.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );

          await FirebaseAuth.instance.signInWithCredential(credential);
        }
      } catch (err) {
        state = state.load(false);
        _showError(err.toString());
      }
    }
  }

  void appleLogin() async {
    if (!state.loggedIn) {
      state = state.load(true);
      try {
        final appleProvider = AppleAuthProvider()
          ..addScope('name')
          ..addScope('email');
        if (kIsWeb) {
          await FirebaseAuth.instance.signInWithPopup(appleProvider);
        } else {
          await FirebaseAuth.instance.signInWithProvider(appleProvider);
        }
      } catch (err) {
        state = state.load(false);
        _showError(err.toString());
      }
    }
  }

  void logout() async {
    if (state.loggedIn) {
      state = state.load(true);
      try {
        _ref.read(classTableProvider.notifier).clear();
        _ref.read(classTableProvider.notifier).dispose();
        await _auth.signOut();
        _ref.read(bottomTabProvider.notifier).state = 0;
      } catch (err) {
        state = AuthState();
        _showError(err.toString());
      }
    }
  }

  void deleteAccount() async {
    if (state.loggedIn) {
      state = state.load(true);
      FirebaseFirestore db = FirebaseFirestore.instance;
      try {
        _ref.read(classTableProvider.notifier).clear();
        _ref.read(classTableProvider.notifier).dispose();
        await db.collection("user").doc(_auth.currentUser!.uid).delete();
        await db
            .collection("user/${_auth.currentUser!.uid}/private")
            .doc('fcm')
            .delete();
        await _auth.currentUser!.delete();
        _ref.read(bottomTabProvider.notifier).state = 0;
      } catch (err) {
        state = AuthState();
        _showError(err.toString());
      }
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

  void joinClass(String classCode, String serialCode) async {
    if (state.loggedIn && state.classCode == null) {
      _showError('正在驗證資料');
      state = state.load(true);
      http
          .post(Uri.parse('http://v2.apis.classtodo.ycydev.org/join_class'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "idToken": await state.user?.getIdToken(),
                "classCode": classCode,
                "serialCode": serialCode
              }))
          .then((res) {
        if (res.statusCode == 200) {
          state = state.classJoined(classCode);
        } else {
          _showError('無法加入：${res.body}');
          state = state.load(false);
        }
      }).catchError((error) {
        _showError(error);
        state = state.load(false);
      });
    }
  }
}

class AuthState {
  AuthState(
      {this.user, this.classCode, this.loading = false, this.init = true});
  final User? user;
  final String? classCode;
  final bool init;
  final bool loading;
  bool get loggedIn => user != null;
  AuthState initialized() =>
      AuthState(user: user, classCode: classCode, loading: loading);
  AuthState load(bool isLoading) =>
      AuthState(user: user, classCode: classCode, loading: isLoading);
  AuthState classJoined(String classCode) =>
      AuthState(user: user, loading: false, classCode: classCode);
}
