import 'dart:async';

import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class SchoolAnnouncementNotifier
    extends StateNotifier<SchoolAnnouncementState> {
  final Ref _ref;
  StreamSubscription<QuerySnapshot>? listener;
  SchoolAnnouncementNotifier(this._ref) : super(SchoolAnnouncementState([])) {
    getData();
  }

  void changeSource(int idx) {
    state = SchoolAnnouncementState([], rssEndPointIdx: idx, loading: true);
    getData();
  }

  void getData() {
    final rssUrl =
        _ref.read(rssUrlProvider).rssEndpoints[state.rssEndPointIdx].url;
    state = state.copy([], loading: true);
    http.get(rssUrl).then((value) {
      if (value.statusCode == 200) {
        if (rssUrl ==
            _ref.read(rssUrlProvider).rssEndpoints[state.rssEndPointIdx].url) {
          final rssFeed = RssFeed.parse(value.body);
          rssFeed.items.sort((a, b) {
            DateTime? dateA = DateFormat('EEE, d MMM yyyy HH:mm:ss')
                .tryParse(a.pubDate ?? '');
            DateTime? dateB = DateFormat('EEE, d MMM yyyy HH:mm:ss')
                .tryParse(b.pubDate ?? '');
            dateA ??= DateTime.now();
            dateB ??= DateTime.now();
            return dateB.compareTo(dateA);
          });
          state = state.copy(rssFeed.items);
        }
      }
    }).catchError((error) {
      state = state.copy([]);
      _showError('RSS網址錯誤。');
    });
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
  void dispose() {
    listener?.cancel();
    super.dispose();
  }
}

class SchoolAnnouncementState {
  int rssEndPointIdx;
  List<RssItem> announcements;
  bool loading;
  SchoolAnnouncementState(this.announcements,
      {this.rssEndPointIdx = 0, this.loading = false});
  SchoolAnnouncementState copy(List<RssItem> announcements,
      {bool loading = false}) {
    return SchoolAnnouncementState(announcements,
        rssEndPointIdx: rssEndPointIdx, loading: loading);
  }
}
