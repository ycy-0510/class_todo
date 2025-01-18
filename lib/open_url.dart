import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String sUrl) async {
  Uri url = Uri.parse(sUrl);
  if (await canLaunchUrl(url)) {
    log(url.scheme, name: 'Open Url');
    switch (url.scheme) {
      case 'mailto':
      case 'tel':
      case 'sms':
        launchUrl(url,
            mode: LaunchMode.platformDefault,
            browserConfiguration: const BrowserConfiguration(showTitle: true));
        break;
      default:
        launchUrl(url,
            mode: LaunchMode.inAppBrowserView,
            browserConfiguration: const BrowserConfiguration(showTitle: true));
    }
  } else {
    log('Can not open.', name: 'Open Url');
  }
}
