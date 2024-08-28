import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/page/setting.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class HomeSchoolBody extends ConsumerWidget {
  const HomeSchoolBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schoolAnnouncementProvider);
    ref.listen(rssUrlProvider, (prev, next) {
      ref.read(schoolAnnouncementProvider.notifier).getData();
    });
    return LoadingView(
        loading: state.loading,
        child: RefreshIndicator(
          onRefresh: () async =>
              ref.read(schoolAnnouncementProvider.notifier).getData(),
          child: Builder(builder: (context) {
            if (ref.watch(rssUrlProvider) == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 50,
                    ),
                    const Text(
                      '請先輸入學校RSS網址',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SettingPage(),
                            )),
                        child: const Text('前往設定'))
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: state.announcements.length,
                itemBuilder: (context, idx) {
                  return ListTile(
                    title: Text(state.announcements[idx].title ?? '無標題'),
                    subtitle: Text('發布於${state.announcements[idx].pubDate}'),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return RssPreview(idx);
                        },
                      ));
                    },
                  );
                },
              );
            }
          }),
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
                              'src="${ref.watch(rssUrlProvider)?.origin}/')
                          .replaceAll('color:', 'c:') ??
                      '') +
                  (state.announcements[idx].content?.value
                          .replaceAll('src="/',
                              'src="${ref.watch(rssUrlProvider)?.origin}/')
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
