import 'package:class_todo_list/error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixPanelNotifier extends Notifier<bool> {
  late Mixpanel mixpanel;

  MixPanelNotifier() : super();

  Future<void> initMixpanel() async {
    try {
      mixpanel =
          await Mixpanel.init("5fed67f82271a1c297b525bc2281f1bd", trackAutomaticEvents: false);
      if (!kIsWeb) {
        mixpanel.setLoggingEnabled(kDebugMode);
      }
    } catch (e) {
      ErrorHelper.handleError(e);
    }
  }

  @override
  bool build() {
    initMixpanel();
    return true;
  }
}
