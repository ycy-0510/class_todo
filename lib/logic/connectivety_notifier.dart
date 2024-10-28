import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { notDetermined, isConnected, isDisonnected }

class ConnectivityStatusNotifier extends StateNotifier<ConnectivityStatus> {
  StreamController<ConnectivityResult> controller =
      StreamController<ConnectivityResult>();

  StreamSubscription<List<ConnectivityResult>>? listener;

  ConnectivityStatusNotifier() : super(ConnectivityStatus.isConnected) {
    late ConnectivityStatus lastResult;
    late ConnectivityStatus newState;

    lastResult = ConnectivityStatus.notDetermined;
    listener = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      for (var result in results) {
        switch (result) {
          case ConnectivityResult.mobile:
          case ConnectivityResult.wifi:
            newState = ConnectivityStatus.isConnected;
            break;
          case ConnectivityResult.none:
            newState = ConnectivityStatus.isDisonnected;
            break;
          default:
            newState = ConnectivityStatus.isDisonnected;
        }
        if (newState != lastResult) {
          state = newState;
          lastResult = newState;
        }
      }
    });
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }
}
