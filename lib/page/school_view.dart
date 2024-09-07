import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';

class HomeSchoolBody extends ConsumerWidget {
  const HomeSchoolBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schoolAnnouncementProvider);
    final readState = ref.watch(rssReadProvider);
    return LoadingView(
        loading: state.loading,
        child: RefreshIndicator(
          onRefresh: () async =>
              ref.read(schoolAnnouncementProvider.notifier).getData(),
          child: ListView.builder(
            itemCount: state.announcements.length,
            itemBuilder: (context, idx) {
              DateTime? publish = DateFormat('EEE, d MMM yyyy HH:mm:ss')
                  .tryParse(state.announcements[idx].pubDate ?? '')
                  ?.add(DateTime.now().timeZoneOffset);
              String? guid = state.announcements[idx].guid;
              if (!ref.watch(rssReadFilterProvider) ||
                  !readState.contains(guid)) {
                return ListTile(
                  title: Text(
                    state.announcements[idx].title ?? '無標題',
                    style: TextStyle(
                        fontWeight:
                            readState.contains(guid) ? null : FontWeight.bold),
                  ),
                  subtitle: publish != null
                      ? Text(
                          '發布於${DateFormat('yyyy-MM-dd HH:mm').format(publish)}')
                      : null,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return RssPreview(idx);
                      },
                    )).then((value) {
                      ref.read(rssReadProvider.notifier).markRead(guid!);
                    });
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ));
  }
}

class RssPreview extends ConsumerWidget {
  const RssPreview(this.idx, {super.key});
  final int idx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schoolAnnouncementProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(state.announcements[idx].title ?? '預覽頁面'),
        actions: [
          IconButton(
              tooltip: '開啟頁面',
              onPressed: () => openUrl(state.announcements[idx].link!),
              icon: const Icon(Icons.open_in_new))
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: SafeArea(
            child: HtmlWidget(
              (state.announcements[idx].description
                          ?.replaceAll('src="/',
                              'src="${ref.watch(rssUrlProvider).rssEndpoints.first.url.origin}/')
                          .replaceAll('color:', 'c:') ??
                      '') +
                  (state.announcements[idx].content?.value
                          .replaceAll('src="/',
                              'src="${ref.watch(rssUrlProvider).rssEndpoints.first.url.origin}/')
                          .replaceAll('color:', 'c:') ??
                      ''),
              onTapUrl: (url) {
                openUrl(url);
                return true;
              },
              renderMode: RenderMode.column,
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
