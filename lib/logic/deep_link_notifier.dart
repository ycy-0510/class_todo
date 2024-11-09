import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeepLinkNotifier extends Notifier<Uri?> {
  final AppLinks _appLinks = AppLinks();
  @override
  build() {
    init();
    return null;
  }

  void init() {
    _appLinks.uriLinkStream.listen((uri) {
      log(uri.toString());
      state = uri;
    });
  }
}
