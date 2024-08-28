import 'dart:convert';

import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthNotifier extends StateNotifier<AuthState> {
  late FirebaseAuth _auth;
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState()) {
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
        if (userData.exists) {
          state = AuthState(user: user, classCode: userData.data()?['class']);
        } else {
          state = AuthState(user: user);
          await db.collection("user").doc(user.uid).set({
            "name": user.displayName,
          });
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
          final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
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

  void logout() async {
    if (state.loggedIn) {
      state = state.load(true);
      try {
        _ref.read(classTableProvider.notifier).clear();
        _ref.read(classTableProvider.notifier).dispose();
        await _auth.signOut();
      } catch (err) {
        state = AuthState();
        _showError(err.toString());
      }
    }
  }

  void _showError(String error) {
    Fluttertoast.showToast(
      msg: error,
      timeInSecForIosWeb: 2,
      webShowClose: true,
    );
  }

  void joinClass(String classCode, String serialCode) async {
    if (state.loggedIn && state.classCode == null) {
      _showError('正在驗證資料');
      state = state.load(true);
      http
          .post(Uri.parse('https://class-todo-server.onrender.com/join_class'),
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
  AuthState({this.user, this.classCode, this.loading = false});
  final User? user;
  final String? classCode;
  final bool loading;
  bool get loggedIn => user != null;
  AuthState load(bool isLoading) =>
      AuthState(user: user, classCode: classCode, loading: isLoading);
  AuthState classJoined(String classCode) =>
      AuthState(user: user, loading: false, classCode: classCode);
}
