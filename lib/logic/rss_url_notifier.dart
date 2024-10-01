import 'package:class_todo_list/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class RssUrlNotifier extends StateNotifier<RssUrlState> {
  final Ref _ref;
  late FirebaseFirestore db;
  RssUrlNotifier(this._ref)
      : super(RssUrlState([
          RssEndPoint('App公告',
              'https://blog.classtodo.ycydev.org/feeds/posts/default?alt=rss')
        ])) {
    db = FirebaseFirestore.instance;
    getRssUrl();
  }

  void getRssUrl() async {
    final userClassCode = _ref.read(authProvider).classCode;
    state = RssUrlState([
      RssEndPoint('App公告',
          'https://blog.classtodo.ycydev.org/feeds/posts/default?alt=rss')
    ]);
    if (!_ref.read(authProvider).user!.isAnonymous) {
      final dataRef = db.collection("class/$userClassCode/config").doc('rss');
      try {
        final usersData = await dataRef.get();
        List<RssEndPoint> rssEndPoints = [];
        if (usersData.exists && usersData.data()?['items'] is Map) {
          final originMap = usersData.data()?['items'] as Map<String, dynamic>;
          final keys = originMap.keys.toList();
          for (var key in keys) {
            rssEndPoints.add(RssEndPoint(key, originMap[key].toString()));
          }
          rssEndPoints.add(RssEndPoint('App公告',
              'https://blog.classtodo.ycydev.org/feeds/posts/default?alt=rss'));
        } else {
          _showError('找不到Rss');
        }
        state = RssUrlState(rssEndPoints);
      } catch (e) {
        _showError(e.toString());
      }
      _ref.read(schoolAnnouncementProvider.notifier).getData();
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
}

class RssUrlState {
  List<RssEndPoint> rssEndpoints;
  RssUrlState(this.rssEndpoints);

  RssUrlState copy() {
    return RssUrlState(rssEndpoints);
  }
}

class RssEndPoint {
  String name;
  late Uri url;
  RssEndPoint(this.name, String _url) {
    url = Uri.parse(_url);
  }
}
