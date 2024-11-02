import 'dart:async';
import 'dart:convert';
import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Timer? autoRenew;
  GoogleApiNotifier(this._ref) : super(GoogleApiState()) {
    init();
  }
  Future<void> init() async {
    final db = FirebaseFirestore.instance;
    try {
      final user = _ref.read(authProvider).user;
      state = GoogleApiState(connected: false);
      if (user != null) {
        final doc =
            await db.collection('user/${user.uid}/private').doc('google').get();
        bool connected =
            doc.exists && doc.data()?['googleRefreshToken'] != null;
        if (connected) {
          renewHttpClient();
        }
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void linkGoogle() async {
    if (!state.connected) {
      try {
        if (kIsWeb) {
        } else {
          final GoogleSignInAccount? googleUser = await GoogleSignIn(
            serverClientId:
                '65396233679-lk81s3r3e7sek4uori1qvmgjni6fcek6.apps.googleusercontent.com',
            scopes: [CalendarApi.calendarReadonlyScope],
            forceCodeForRefreshToken: true,
          ).signIn().catchError((onError) => null);
          toastification.show(
            type: ToastificationType.info,
            style: ToastificationStyle.flatColored,
            title: const Text("正在連接Google行事曆"),
            alignment: Alignment.topCenter,
            showProgressBar: false,
            autoCloseDuration: const Duration(milliseconds: 1500),
          );
          final res = await http.post(
              Uri.parse(
                  '${_ref.read(remoteConfigProvider.notifier).getServerUrl()}/google_api/connect'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'idToken': await _ref.read(authProvider).user?.getIdToken(),
                'serverAuthCode': googleUser!.serverAuthCode
              }));
          if (res.statusCode == 200) {
            toastification.show(
              type: ToastificationType.success,
              style: ToastificationStyle.flatColored,
              title: const Text("連接Google行事曆成功"),
              alignment: Alignment.topCenter,
              showProgressBar: false,
              autoCloseDuration: const Duration(milliseconds: 1500),
            );
            renewHttpClient();
          } else {
            _showError('連接失敗：${res.body}');
          }
        }
      } catch (err) {
        _showError(err.toString());
      }
    }
  }

  void unlink() async {
    if (state.connected) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(key, false);
      state = GoogleApiState();
      autoRenew?.cancel();
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final res = await http.post(
          Uri.parse(
              '${_ref.read(remoteConfigProvider.notifier).getServerUrl()}/google_api/get_access_token'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'idToken': await _ref.read(authProvider).user?.getIdToken(),
          }));
      if (res.statusCode == 200) {
        return json.decode(res.body)['accessToken'];
      } else {
        throw Exception('Failed to get access token');
      }
    } catch (error) {
      _showError(error.toString());
    }
    return null;
  }

  Future<int?> getAccessTokenExpiredTime(String accessToken) async {
    try {
      final res = await http.get(Uri.parse(
          'https://www.googleapis.com/oauth2/v1/tokeninfo/?access_token=$accessToken'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['expires_in'];
      } else {
        throw Exception('Failed to get token info');
      }
    } catch (error) {
      _showError(error.toString());
      return null;
    }
  }

  Future<void> renewHttpClient() async {
    autoRenew = null;
    try {
      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        state = state.error();
        return;
      }
      int? expiredTime = await getAccessTokenExpiredTime(accessToken);
      state = state.updateClient(
          GoogleHttpClient({'Authorization': 'Bearer $accessToken'}));
      autoRenew =
          Timer(Duration(seconds: (expiredTime ?? 3600) - 30), renewHttpClient);
    } catch (error) {
      _showError(error.toString());
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
  GoogleApiState(
      {this.connected = false, this.googleHttpClient, this.hasError = false});
  final bool connected;
  final GoogleHttpClient? googleHttpClient;
  final bool hasError;

  GoogleApiState updateClient(GoogleHttpClient client) =>
      GoogleApiState(connected: true, googleHttpClient: client);

  GoogleApiState error() => GoogleApiState(connected: true, hasError: true);
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
