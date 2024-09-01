import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RssUrlNumberNotifier extends StateNotifier<Uri?> {
  static String key = 'rssUrl';
  RssUrlNumberNotifier() : super(null) {
    getUrl();
  }

  Future<void> getUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final rssUrl = Uri.tryParse(
      prefs.getString(key) ?? '::Not valid URI::',
    );
    state = rssUrl;
  }

  Future<void> setUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final rssUrl = url.contains('.edu.tw/') ? Uri.tryParse(url) : null;
    prefs.setString(key, rssUrl == null ? '::Not valid URI::' : url);
    state = rssUrl;
  }
}
