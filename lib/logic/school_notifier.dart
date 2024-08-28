import 'dart:async';

import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class SchoolAnnouncementNotifier
    extends StateNotifier<SchoolAnnouncementState> {
  final Ref _ref;
  StreamSubscription<QuerySnapshot>? listener;
  SchoolAnnouncementNotifier(this._ref) : super(SchoolAnnouncementState([])) {
    getData();
  }

  void getData() {
    final rssUrl = _ref.read(rssUrlProvider);
    if (rssUrl != null) {
      state = SchoolAnnouncementState([], loading: true);
      http.get(_ref.read(rssUrlProvider)!).then((value) {
        if (value.statusCode == 200) {
          final rssFeed = RssFeed.parse(value.body);
          state = SchoolAnnouncementState(rssFeed.items);
        }
      }).catchError((error) {
        state = SchoolAnnouncementState([]);
        _showError('請於設定中檢查RSS網址是否有效。');
      });
    }
  }

  void _showError(String error) {
    Fluttertoast.showToast(
      msg: error,
      timeInSecForIosWeb: 2,
      webShowClose: true,
    );
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }
}

class SchoolAnnouncementState {
  List<RssItem> announcements;
  bool loading;
  SchoolAnnouncementState(this.announcements, {this.loading = false});
}
