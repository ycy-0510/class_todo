import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toastification/toastification.dart';

class RemoteConfigNotifier extends Notifier<bool> {
  late final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigNotifier() : super() {
    _remoteConfig = FirebaseRemoteConfig.instance;
  }

  void init() async {
    try {
      await _remoteConfig.ensureInitialized();
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults({
        "server_url": 'https://v2.apis.classtodo.ycydev.org',
        "version": (await PackageInfo.fromPlatform()).version,
        "allow_cancel_update": true
      });
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  String getServerUrl() => _remoteConfig.getString('server_url');
  String getRequiredVersion() => _remoteConfig.getString('version');
  bool getAllowCancelUpdate() => _remoteConfig.getBool('allow_cancel_update');

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

  @override
  bool build() {
    init();
    return true;
  }
}
