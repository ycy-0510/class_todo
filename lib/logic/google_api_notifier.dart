import 'dart:async';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class GoogleApiNotifier extends StateNotifier<GoogleApiState> {
  final Ref _ref;
  String key = 'linkGoogle';
  GoogleApiNotifier(this._ref) : super(GoogleApiState()) {
    init();
    _ref.listen(authProvider, (prev, next) {
      if (!next.loggedIn) {
        unlink();
      }
    });
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool(key) ?? false;
    try {
      state = GoogleApiState(loggedIn: false);
      if (loggedIn) {
        final GoogleSignInAccount? googleUser = await GoogleSignIn(
          forceCodeForRefreshToken: true,
          scopes: [CalendarApi.calendarReadonlyScope],
        ).signInSilently().catchError((onError) => null);
        GoogleHttpClient httpClient =
            GoogleHttpClient(await googleUser!.authHeaders);
        state = state.updateClient(httpClient, DateTime.now());
      }
    } catch (e) {
      _showError(e.toString());
    }

    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (state.loggedIn) {
        try {
          final GoogleSignInAccount? googleUser = await GoogleSignIn(
            scopes: [CalendarApi.calendarReadonlyScope],
          ).signInSilently().catchError((onError) => null);
          GoogleHttpClient httpClient =
              GoogleHttpClient(await googleUser!.authHeaders);
          state = state.updateClient(httpClient, DateTime.now());
        } catch (e) {
          _showError(e.toString());
        }
      }
    });
  }

  void linkGoogle() async {
    if (!state.loggedIn) {
      try {
        if (kIsWeb) {
        } else {
          final GoogleSignInAccount? googleUser = await GoogleSignIn(
            scopes: [CalendarApi.calendarReadonlyScope],
            forceCodeForRefreshToken: true,
          ).signIn().catchError((onError) => null);
          final httpClient = GoogleHttpClient(await googleUser!.authHeaders);
          state = GoogleApiState(
            loggedIn: true,
            googleHttpClient: httpClient,
          );
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool(key, true);
        }
      } catch (err) {
        _showError(err.toString());
      }
    }
  }

  void unlink() async {
    if (state.loggedIn) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(key, false);
      state = GoogleApiState();
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

class GoogleApiState {
  GoogleApiState({this.loggedIn = false, this.googleHttpClient});
  final bool loggedIn;
  final GoogleHttpClient? googleHttpClient;

  GoogleApiState updateClient(GoogleHttpClient client, DateTime dateTime) =>
      GoogleApiState(loggedIn: true, googleHttpClient: client);
}

class GoogleHttpClient extends IOClient {
  final Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url, headers: headers!..addAll(_headers));
}
