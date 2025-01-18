import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:toastification/toastification.dart';

class MixPanelNotifier extends Notifier<bool> {
  late Mixpanel mixpanel;

  MixPanelNotifier() : super();

  Future<void> initMixpanel() async {
    try {
      mixpanel = await Mixpanel.init("5fed67f82271a1c297b525bc2281f1bd",
          trackAutomaticEvents: false);
      if (!kIsWeb) {
        mixpanel.setLoggingEnabled(kDebugMode);
      }
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

  @override
  bool build() {
    initMixpanel();
    return true;
  }
}
