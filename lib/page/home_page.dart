import 'package:class_todo_list/adaptive_action.dart';
import 'package:class_todo_list/logic/connectivety_notifier.dart';
import 'package:class_todo_list/logic/rss_url_notifier.dart';
import 'package:class_todo_list/page/intro_page.dart';
import 'package:class_todo_list/page/more_view.dart';
import 'package:class_todo_list/page/school_view.dart';
import 'package:class_todo_list/page/submit_view.dart';
import 'package:class_todo_list/page/task_view.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<_HomePageState> homeKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      bool showedIntro = prefs.getBool('intro') ?? false;
      if (!showedIntro) {
        Future.delayed(const Duration(seconds: 1)).then((_) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const IntroPage()),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notificationProvider, (prev, next) {
      if (prev?.openBottomSheet != next.openBottomSheet &&
          next.openBottomSheet) {
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (context) => SizedBox(
            height: 700,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications,
                            size: 30,
                          ),
                          Text(
                            '接收通知',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ]),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Image.asset(
                        'assets/img/notification.png',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        '我們需要通知權限才能發送「每日提醒」和「最新消息」給您，稍後您也可以在「更多>個人帳號設定」中調整通知發送時間。',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(notificationProvider.notifier)
                              .requestPermission();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text(
                          '開啟通知',
                          style: TextStyle(fontSize: 20),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ref
                              .read(notificationProvider.notifier)
                              .closeBottomSheet();
                        },
                        child: const Text(
                          '稍後設定',
                          style: TextStyle(fontSize: 20),
                        ))
                  ],
                ),
              ),
            ),
          ),
        );
      }
    });

    ref.watch(usersProvider);
    ref.watch(usersNumberProvider);
    ref.watch(taskProvider);
    ref.watch(calendarTaskProvider);
    RssUrlState rssUrlState = ref.watch(rssUrlProvider);
    TaskViewType taskViewTypeState = ref.watch(taskViewTypeProvider);
    int schoolAnnouncementSource =
        ref.watch(schoolAnnouncementProvider).rssEndPointIdx;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: [
          const Text(
            '所有項目',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const Text(
            '繳交列表',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const Text(
            '學校公告',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const Text(
            '更多',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ][ref.watch(bottomTabProvider)],
        actions: [
          if (ref.watch(bottomTabProvider) == 0 &&
              ref.watch(taskViewTypeProvider) != TaskViewType.calendar)
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
              icon: const Icon(
                Icons.add_task,
                color: Colors.blue,
              ),
            ),
          if (ref.watch(bottomTabProvider) == 2) ...[
            IconButton(
              onPressed: () => showAdaptiveDialog(
                context: context,
                builder: (context) => AlertDialog.adaptive(
                  title: const Text('是否全部已讀'),
                  content: const Text('此操作將無法復原！'),
                  actions: [
                    AdaptiveAction(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        toastification.show(
                          type: ToastificationType.info,
                          style: ToastificationStyle.flatColored,
                          title: const Text("已全部標示已讀"),
                          alignment: Alignment.topCenter,
                          showProgressBar: false,
                          autoCloseDuration: const Duration(milliseconds: 1500),
                        );
                      },
                      danger: true,
                      child: const Text('已讀'),
                    ),
                    AdaptiveAction(
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
              }),
              icon: const Icon(
                Icons.done_all,
                color: Colors.blue,
              ),
              tooltip: '標示已讀',
            ),
            IconButton(
              onPressed: () => ref
                  .read(rssReadFilterProvider.notifier)
                  .update((state) => !state),
              icon: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    color:
                        ref.watch(rssReadFilterProvider) ? Colors.blue : null),
                padding: const EdgeInsets.all(1.5),
                child: Icon(
                  Icons.filter_list,
                  color: ref.watch(rssReadFilterProvider)
                      ? Theme.of(context).scaffoldBackgroundColor
                      : Colors.blue,
                ),
              ),
              tooltip: '過濾',
            ),
            IconButton(
              onPressed: () => showSearch(
                  context: context,
                  delegate: AnnounceSearchDelegate(
                      ref.read(schoolAnnouncementProvider).announcements)),
              icon: const Icon(Icons.search),
              color: Colors.blue,
              tooltip: '搜尋公告',
            )
          ],
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
                                    icon: Icon(Icons.list),
                                  ),
                                  ButtonSegment<TaskViewType>(
                                    value: TaskViewType.calendar,
                                    label: Text('個人'),
                                    icon: Icon(Icons.person),
                                  ),
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
        const HomeMoreBody(),
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
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.shapes), label: '更多'),
        ],
        onTap: (value) => ref.read(bottomTabProvider.notifier).state = value,
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
