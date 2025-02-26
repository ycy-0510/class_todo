import 'dart:async';
import 'dart:convert';

import 'package:class_todo_list/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class RssReadNotifier extends StateNotifier<List<String>> {
  final Ref _ref;
  RssReadNotifier(this._ref) : super([]) {
    getData();
    _ref.listen(schoolAnnouncementProvider, (previous, next) {
      getData();
    });
  }

  SharedPreferences get _sharedPreferences =>
      _ref.read(sharedPreferencesProvider).requireValue;

  Future<void> getData() async {
    int rssIndex = _ref.read(schoolAnnouncementProvider).rssEndPointIdx;
    String key = sha256
        .convert(utf8.encode(
            _ref.read(rssUrlProvider).rssEndpoints[rssIndex].url.origin))
        .toString();
    List<String> rssReadList = _sharedPreferences.getStringList(key) ?? [];
    state = rssReadList;
  }

  Future<void> markRead(String id) async {
    int rssIndex = _ref.read(schoolAnnouncementProvider).rssEndPointIdx;
    String key = sha256
        .convert(utf8.encode(
            _ref.read(rssUrlProvider).rssEndpoints[rssIndex].url.origin))
        .toString();
    List<String> rssReadList =
        List.generate(state.length, (index) => state[index]);
    if (rssReadList.contains(id)) {
      return;
    } else {
      rssReadList.add(id);
    }
    _sharedPreferences.setStringList(key, rssReadList);
    state = rssReadList;
  }

  Future<void> markUnread(String id) async {
    int rssIndex = _ref.read(schoolAnnouncementProvider).rssEndPointIdx;
    String key = sha256
        .convert(utf8.encode(
            _ref.read(rssUrlProvider).rssEndpoints[rssIndex].url.origin))
        .toString();
    List<String> rssReadList =
        List.generate(state.length, (index) => state[index]);
    if (rssReadList.contains(id)) {
      rssReadList.remove(id);
    } else {
      return;
    }
    _sharedPreferences.setStringList(key, rssReadList);
    state = rssReadList;
  }

  Future<void> readAll() async {
    int rssIndex = _ref.read(schoolAnnouncementProvider).rssEndPointIdx;
    String key = sha256
        .convert(utf8.encode(
            _ref.read(rssUrlProvider).rssEndpoints[rssIndex].url.origin))
        .toString();
    List<String> rssReadList =
        List.generate(state.length, (index) => state[index]);
    for (var item in _ref.read(schoolAnnouncementProvider).announcements) {
      String? id = item.guid;
      if (rssReadList.contains(id) || id == null) {
        continue;
      } else {
        rssReadList.add(id);
      }
    }
    _sharedPreferences.setStringList(key, rssReadList);
    state = rssReadList;
  }
}
