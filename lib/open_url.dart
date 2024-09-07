import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String sUrl) async {
  Uri url = Uri.parse(sUrl);
  if (await canLaunchUrl(url)) {
    launchUrl(url,
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true));
  }
}
