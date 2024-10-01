import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:dart_rss/dart_rss.dart';
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
    final showAnnouncements = state.announcements
        .where((item) =>
            !ref.watch(rssReadFilterProvider) || !readState.contains(item.guid))
        .toList();

    return LoadingView(
        loading: state.loading,
        child: RefreshIndicator(
          onRefresh: () async =>
              ref.read(schoolAnnouncementProvider.notifier).getData(),
          child: AnnouncesListView(showAnnouncements),
        ));
  }
}

class AnnouncesListView extends ConsumerWidget {
  const AnnouncesListView(this.announces, {super.key});
  final List<RssItem> announces;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readState = ref.watch(rssReadProvider);

    return ListView.separated(
      itemCount: announces.length,
      itemBuilder: (context, idx) {
        DateTime? publish = DateFormat('EEE, d MMM yyyy HH:mm:ss')
            .tryParse(announces[idx].pubDate ?? '')
            ?.add(DateTime.now().timeZoneOffset);
        String? guid = announces[idx].guid;
        return Card(
          clipBehavior: Clip.hardEdge,
          margin: announces.length == 1
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
              : idx == 0
                  ? const EdgeInsets.fromLTRB(20, 10, 20, 0)
                  : idx == announces.length - 1
                      ? const EdgeInsets.fromLTRB(20, 0, 20, 10)
                      : const EdgeInsets.symmetric(horizontal: 20),
          shape: announces.length == 1
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
              : idx == 0
                  ? const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25)))
                  : idx == announces.length - 1
                      ? const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25)))
                      : const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            minLeadingWidth: 15,
            leading: readState.contains(guid)
                ? const SizedBox.shrink()
                : const Icon(
                    Icons.circle,
                    color: Colors.blue,
                    size: 15,
                  ),
            title: Text(
              announces[idx].title ?? '無標題',
              style: TextStyle(
                  fontWeight:
                      readState.contains(guid) ? null : FontWeight.bold),
            ),
            subtitle: publish != null
                ? Text(
                    '發布於${DateFormat('yyyy/MM/dd HH:mm', 'zh-TW').format(publish)}')
                : null,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return RssPreview(
                      announces[idx].title,
                      announces[idx].description,
                      announces[idx].content?.value,
                      announces[idx].link);
                },
              ));
              ref.read(rssReadProvider.notifier).markRead(guid!);
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        height: 0,
        indent: 60,
        endIndent: 20,
      ),
    );
  }
}

class AnnounceSearchDelegate extends SearchDelegate {
  AnnounceSearchDelegate(this.announces);
  final List<RssItem> announces;
  List<RssItem> results = <RssItem>[];

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query.isEmpty ? close(context, null) : query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => results.isEmpty
      ? const Center(
          child: Text('找不到這項公告', style: TextStyle(fontSize: 24)),
        )
      : AnnouncesListView(results);

  @override
  Widget buildSuggestions(BuildContext context) {
    results = announces.where((RssItem item) {
      final String title = item.title?.toLowerCase() ?? '';
      final String description = item.description?.toLowerCase() ?? '';
      final String content = item.content?.value.toLowerCase() ?? '';
      final String input = query.toLowerCase();
      return title.contains(input) ||
          description.contains(input) ||
          content.contains(input);
    }).toList();
    return results.isEmpty
        ? const Center(
            child: Text('找不到這項公告', style: TextStyle(fontSize: 24)),
          )
        : AnnouncesListView(results);
  }
}

class RssPreview extends ConsumerWidget {
  const RssPreview(this.title, this.description, this.content, this.link,
      {super.key});
  final String? title;
  final String? description;
  final String? content;
  final String? link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? '預覽頁面'),
        actions: [
          IconButton(
              tooltip: '開啟頁面',
              onPressed: () => openUrl(link!),
              icon: const Icon(Icons.open_in_new))
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: SafeArea(
            child: HtmlWidget(
              (description
                          ?.replaceAll('src="/',
                              'src="${ref.watch(rssUrlProvider).rssEndpoints.first.url.origin}/')
                          .replaceAll('color:', 'c:') ??
                      '') +
                  (content
                          ?.replaceAll('src="/',
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
