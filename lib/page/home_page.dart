import 'package:class_todo_list/logic/connectivety_notifier.dart';
import 'package:class_todo_list/logic/rss_url_notifier.dart';
import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/page/school_view.dart';
import 'package:class_todo_list/page/setting.dart';
import 'package:class_todo_list/page/submit_view.dart';
import 'package:class_todo_list/page/task_view.dart';
import 'package:class_todo_list/page/users_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String version = '';
    String buildNumber = '';
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
    //version
    ref.watch(usersProvider);
    ref.watch(usersNumberProvider);
    ref.watch(taskProvider);
    RssUrlState rssUrlState = ref.watch(rssUrlProvider);
    TaskViewType taskViewTypeState = ref.watch(taskViewTypeProvider);
    int schoolAnnouncementSource =
        ref.watch(schoolAnnouncementProvider).rssEndPointIdx;
    String? classCode = ref.watch(authProvider).classCode;
    return Scaffold(
      appBar: AppBar(
        title: Text('共享聯絡簿 $classCode'),
        actions: [
          if (ref.watch(bottomTabProvider) == 0)
            IconButton(
              tooltip: '新增事項',
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(formProvider.notifier).dateChange(DateTime.now());
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => const TaskForm());
              },
              icon: const Icon(Icons.add_task),
            ),
          if (ref.watch(bottomTabProvider) == 2)
            PopupMenu<int>(
              icon: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Theme.of(context).iconTheme.color ?? Colors.blue,
                    ),
                    color: ref.watch(rssReadFilterProvider)
                        ? Theme.of(context).iconTheme.color ?? Colors.blue
                        : null),
                padding: const EdgeInsets.all(1.5),
                child: Icon(
                  Icons.filter_list,
                  color: ref.watch(rssReadFilterProvider)
                      ? Theme.of(context).scaffoldBackgroundColor
                      : Theme.of(context).iconTheme.color ?? Colors.blue,
                ),
              ),
              item: const [
                PopupMenuItem(
                  value: 0,
                  child: Text('全部已讀'),
                ),
              ],
              onPressed: () => ref
                  .read(rssReadFilterProvider.notifier)
                  .update((state) => !state),
              onSelected: (value) {
                switch (value) {
                  case 0:
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('是否全部已讀'),
                        content: const Text('此操作將無法復原！'),
                        actions: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('已讀'),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('取消'),
                          )
                        ],
                      ),
                    ).then((value) {
                      if (value == true) {
                        ref.read(rssReadProvider.notifier).readAll();
                      }
                    });
                    break;
                }
              },
            ),
        ],
        bottom: ref.watch(bottomTabProvider) == 0
            ? MediaQuery.of(context).size.width > 800 &&
                    MediaQuery.of(context).size.width >
                        MediaQuery.of(context).size.height
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<TaskViewType>(
                                segments: const <ButtonSegment<TaskViewType>>[
                                  ButtonSegment<TaskViewType>(
                                      value: TaskViewType.table,
                                      label: Text('課表'),
                                      icon: Icon(Icons.table_chart)),
                                  ButtonSegment<TaskViewType>(
                                      value: TaskViewType.list,
                                      label: Text('清單'),
                                      icon: Icon(Icons.list)),
                                ],
                                selected: <TaskViewType>{
                                  taskViewTypeState
                                },
                                onSelectionChanged:
                                    (Set<TaskViewType> newSelection) {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(taskViewTypeProvider.notifier)
                                      .update((state) => newSelection.first);
                                }),
                          ),
                        ],
                      ),
                    ),
                  )
            : ref.watch(bottomTabProvider) == 2
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<int>(
                                segments: <ButtonSegment<int>>[
                                  for (int idx = 0;
                                      idx < rssUrlState.rssEndpoints.length;
                                      idx++)
                                    ButtonSegment<int>(
                                      value: idx,
                                      label: Text(
                                          rssUrlState.rssEndpoints[idx].name),
                                    ),
                                ],
                                selected: <int>{
                                  schoolAnnouncementSource
                                },
                                onSelectionChanged: (Set<int> idx) {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(schoolAnnouncementProvider.notifier)
                                      .changeSource(idx.first);
                                }),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
      ),
      body: SafeArea(
          child: [
        const HomeTaskBody(),
        const HomeSubmittedBody(),
        const HomeSchoolBody(),
      ][ref.watch(bottomTabProvider)]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: ref.watch(bottomTabProvider),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_outlined), label: '所有項目'),
          BottomNavigationBarItem(
              icon: Icon(Icons.text_snippet_outlined), label: '繳交列表'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: '學校公告'),
        ],
        onTap: (value) => ref.read(bottomTabProvider.notifier).state = value,
      ),
      drawer: Drawer(
        child: SafeArea(
            child: Column(
          children: [
            DrawerHeader(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: ref.watch(authProvider).user?.photoURL == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: ColoredBox(
                            color: Colors.blueGrey,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                height: 85,
                                width: 85,
                                child: Center(
                                  child: Text(
                                    (ref
                                            .watch(authProvider)
                                            .user
                                            ?.displayName ??
                                        '訪客')[0],
                                    style: const TextStyle(
                                        fontSize: 50, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            ref.watch(authProvider).user?.photoURL ?? '',
                            height: 85,
                          ),
                        ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ref.watch(authProvider).user?.displayName ?? '訪客',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const SettingPage())),
                      icon: const Icon(Icons.settings),
                      label: const Text(
                        '個人設定',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            )),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('班級成員'),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UsersPage())),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('關於這個app'),
              onTap: () => showAboutDialog(
                  context: context,
                  applicationName: '共享聯絡簿',
                  applicationVersion: 'V$version ($buildNumber)',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/img/icon.png',
                      height: 80,
                    ),
                  ),
                  applicationLegalese:
                      'Copyright © 2024 YCY, Licensed under the Apache License, Version 2.0.'),
            ),
            ListTile(
              leading: const Icon(Icons.web),
              title: const Text('官方網頁'),
              onTap: () => openUrl('https://sites.google.com/view/classtodo'),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.dev),
              title: const Text('開發者網頁'),
              onTap: () => openUrl('https://sites.google.com/view/ycyprogram'),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('線上支援'),
              onTap: () => openUrl('https://tawk.to/ycyprogram'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('開放原始碼'),
              onTap: () => openUrl('https://github.com/ycy-0510/class_todo'),
            ),
          ],
        )),
      ),
    );
  }
}

class LoadingView extends ConsumerWidget {
  const LoadingView({required this.loading, required this.child, super.key});

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(connectivityStatusProvider) ==
        ConnectivityStatus.isConnected) {
      if (!loading) {
        return child;
      } else {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 20,
              ),
              Text('共享聯絡簿 by YCY'),
            ],
          ),
        );
      }
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 50,
            ),
            Text('您已離線，請連接網路以繼續使用'),
            SizedBox(
              height: 20,
            ),
            Text('共享聯絡簿 by YCY'),
          ],
        ),
      );
    }
  }
}

class PopupMenu<T> extends ConsumerStatefulWidget {
  const PopupMenu(
      {super.key,
      required this.icon,
      required this.item,
      this.onPressed,
      required this.onSelected});
  final Widget icon;
  final List<PopupMenuEntry<T>> item;
  final VoidCallback? onPressed;
  final void Function(T value) onSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PopupMenuState<T>();
}

class _PopupMenuState<T> extends ConsumerState<PopupMenu<T>> {
  GlobalKey key = GlobalKey();

  void _showPopupMenu(BuildContext context) async {
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final Offset tapDownPosition = renderBox.localToGlobal(Offset.zero);
    final result = await showMenu<T>(
        context: context,
        position: RelativeRect.fromRect(
          Rect.fromLTWH(tapDownPosition.dx, tapDownPosition.dy + 40, 30, 30),
          Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
              overlay.paintBounds.size.height),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        items: widget.item);
    if (result != null) {
      widget.onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: widget.onPressed,
      onLongPress: () => _showPopupMenu(context),
      child: Padding(
        key: key,
        padding: const EdgeInsets.all(8),
        child: widget.icon,
      ),
    );
  }
}
