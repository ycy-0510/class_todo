import 'package:class_todo_list/class_config.dart';
import 'package:class_todo_list/logic/annouce_notifier.dart';
import 'package:class_todo_list/logic/connectivety_notifier.dart';
// import 'package:class_todo_list/logic/file_notifier.dart';
import 'package:class_todo_list/logic/form_notifier.dart';
import 'package:class_todo_list/logic/submit_notifier.dart';
import 'package:class_todo_list/logic/task_notifier.dart';
import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/page/users_page.dart';
import 'package:class_todo_list/provider.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:photo_view/photo_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(usersProvider);
    ref.watch(usersNumberProvider);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(),
        title: const Text('共享聯絡簿'),
        // actions: [
        //   if (ref.watch(bottomTabProvider) == 3)
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: IconButton(
        //         onPressed: () => ref.read(fileProvider.notifier).getFilesList(),
        //         icon: const Icon(Icons.refresh),
        //         tooltip: '重新載入',
        //       ),
        //     )
        // ],
        bottom: ref.watch(bottomTabProvider) != 0
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () =>
                            ref.read(dateProvider.notifier).lastWeek(),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        tooltip: '上週',
                      ),
                      OutlinedButton(
                          onPressed: () =>
                              ref.read(dateProvider.notifier).today(),
                          child: const Text(
                            '今天',
                            style: TextStyle(fontSize: 18),
                          )),
                      IconButton(
                        onPressed: () =>
                            ref.read(dateProvider.notifier).nextWeek(),
                        icon: const Icon(Icons.arrow_forward_ios),
                        tooltip: '下週',
                      ),
                    ],
                  ),
                ),
              ),
      ),
      body: [
        const HomeTaskBody(),
        const HomeSubmittedBody(),
        const HomeAnnounceBody(),
        // const HomeFileView(),
      ][ref.watch(bottomTabProvider)],
      floatingActionButton: ![0, 3].contains(ref.watch(bottomTabProvider)) ||
              ref.watch(authProvider).user!.isAnonymous
          ? null
          : Builder(builder: (context) {
              switch (ref.watch(bottomTabProvider)) {
                case 0:
                  return FloatingActionButton(
                    tooltip: '新增事項',
                    onPressed: () {
                      ref
                          .read(formProvider.notifier)
                          .dateChange(DateTime.now());
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) => const TaskForm());
                    },
                    child: const Icon(Icons.add_task),
                  );
                // case 3:
                //   return FloatingActionButton(
                //     tooltip: '上傳檔案',
                //     onPressed: () async {
                //       try {
                //         var picked = await FilePicker.platform
                //             .pickFiles(type: FileType.media);
                //         if (picked != null) {
                //           if (picked.files.first.size / (1024 * 1024) <= 4) {
                //             ref.read(fileProvider.notifier).uploadFile(
                //                 picked.files.first.bytes!,
                //                 picked.files.first.name);
                //           } else {
                //             Fluttertoast.showToast(msg: '檔案過大');
                //           }
                //         }
                //       } catch (e) {
                //         Fluttertoast.showToast(msg: e.toString());
                //       }
                //     },
                //     child: const Icon(Icons.file_upload_outlined),
                //   );
                default:
                  return const SizedBox();
              }
            }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: ref.watch(bottomTabProvider),
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_outlined), label: '所有項目'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.text_snippet_outlined), label: '繳交列表'),
          BottomNavigationBarItem(
              icon: Builder(builder: (context) {
                bool showNewMsg = false;
                if (ref.watch(announceProvider).announces.isNotEmpty) {
                  if (ref.watch(announceReadProvider) !=
                      ref.watch(announceProvider).announces.first.announceId) {
                    showNewMsg = true;
                  }
                }
                return Badge(
                  label: showNewMsg ? const Text('N') : null,
                  isLabelVisible: showNewMsg,
                  child: const Icon(Icons.announcement_outlined),
                );
              }),
              label: '最新公告'),
          // const BottomNavigationBarItem(
          //     icon: Icon(Icons.file_open), label: '共享檔案'),
        ],
        onTap: (value) {
          ref.read(bottomTabProvider.notifier).state = value;
          if (value == 2) {
            ref.watch(announceReadProvider.notifier).readMsg(
                ref.watch(announceProvider).announces.first.announceId);
          }
        },
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
                          child: const ColoredBox(
                            color: Colors.green,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.person,
                                size: 80,
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
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        '登出',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            )),
            ListTile(
              enabled: !ref.watch(authProvider).user!.isAnonymous,
              leading: const Icon(Icons.people),
              title: const Text('成員'),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UsersPage())),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('關於這個app'),
              onTap: () => showAboutDialog(
                  context: context,
                  applicationName: '共享聯絡簿',
                  applicationVersion: 'V1.3.0',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/img/logo.png',
                      height: 90,
                    ),
                  ),
                  applicationLegalese:
                      'Copyright © 2023 YCY, Licensed under the Apache License, Version 2.0.'),
            ),
            ListTile(
              leading: const Icon(Icons.web),
              title: const Text('官方網頁'),
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
            ListTile(
              title: Image.asset('assets/img/coffee-button.png'),
              onTap: () => openUrl('https://www.buymeacoffee.com/ckycy'),
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

class HomeTaskBody extends ConsumerWidget {
  const HomeTaskBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TaskState taskState = ref.watch(taskProvider);
    List<Task> tasks = taskState.tasks;
    List<Task> showTasks = [];
    List<Task> importantTasks = [];
    bool showPast = ref.watch(pastSwitchProvider);
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].date.isAfter(ref.watch(nowTimeProvider)) || showPast) {
        showTasks.add(tasks[i]);
      }
    }
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].date.isAfter(ref.watch(nowTimeProvider)) && tasks[i].top) {
        importantTasks.add(tasks[i]);
      }
    }

    return LoadingView(
      loading: taskState.loading,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Icon(Icons.push_pin),
                  Text(
                    '置頂',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            TaskListView(
              importantTasks,
              canScroll: false,
              short: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Icon(Icons.table_chart),
                  Text(
                    '整週課表',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            TaskTableView(tasks),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Icon(Icons.list),
                      Text(
                        '整週項目表',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        '顯示過去項目',
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Switch(
                        value: showPast,
                        onChanged: (value) => ref
                            .read(pastSwitchProvider.notifier)
                            .update((state) => value),
                      ),
                    ],
                  )
                ],
              ),
            ),
            TaskListView(
              showTasks,
              showDateTitle: true,
              canScroll: false,
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '共享聯絡簿 by YCY',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSubmittedBody extends ConsumerWidget {
  const HomeSubmittedBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, String> usersNumber = ref.watch(usersNumberProvider);
    SubmittedState submittedState = ref.watch(submittedProvider);
    Map<String, String> usersData = ref.watch(usersProvider);
    return LoadingView(
      loading: submittedState.loading,
      child: ListView.builder(
        itemCount: submittedState.submittedItems.length,
        itemBuilder: (context, idx) {
          Submitted submitted = submittedState.submittedItems[idx];
          bool done = submitted.done.contains(usersNumber.keys.firstWhere(
              (k) =>
                  usersNumber[k] == ref.watch(authProvider).user!.displayName,
              orElse: () => ''));
          return ListTile(
            leading: Icon(Icons.text_snippet_outlined,
                color: done ||
                        !usersNumber.values
                            .contains(ref.watch(authProvider).user!.displayName)
                    ? null
                    : Colors.red),
            title: Text(
              '${submitted.name} ${submitted.done.length}/${numbersOfClass.length}',
              style: TextStyle(
                  color: done ||
                          !usersNumber.values.contains(
                              ref.watch(authProvider).user!.displayName)
                      ? null
                      : Colors.red),
            ),
            subtitle: Wrap(
              spacing: 5,
              children: [
                Text(usersData[submitted.userId] ?? '未知使用者'),
                Text('截止日期：${submitted.date.toString().substring(0, 16)}'),
              ],
            ),
            trailing: !usersNumber.values
                    .contains(ref.watch(authProvider).user!.displayName)
                ? null
                : Text(
                    done ? '已繳交' : '缺交',
                    style: TextStyle(
                        fontSize: 15, color: done ? Colors.green : Colors.red),
                  ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SubmittedDone(submitted.submittedId))),
          );
        },
      ),
    );
  }
}

class SubmittedDone extends ConsumerWidget {
  const SubmittedDone(this.submittedId, {super.key});

  final String submittedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SubmittedState submittedState = ref.watch(submittedProvider);
    bool available = true;
    Submitted submitted = submittedState.submittedItems.firstWhere(
      (element) => element.submittedId == submittedId,
      orElse: () {
        available = false;
        return Submitted(
            name: '',
            date: DateTime.now(),
            userId: '',
            submittedId: submittedId,
            done: []);
      },
    );
    Map<String, String> usersNumber = ref.watch(usersNumberProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${submitted.name} ${submitted.done.length}/${numbersOfClass.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: submitted.userId != ref.watch(authProvider).user!.uid
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController controller =
                              TextEditingController();
                          return SimpleDialog(
                            contentPadding: const EdgeInsets.all(20),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('發送繳交通知'),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      ref
                                          .read(formProvider.notifier)
                                          .editFinish();
                                    },
                                    icon: const Icon(Icons.close))
                              ],
                            ),
                            children: [
                              SizedBox(
                                width: 300,
                                child: TextFormField(
                                  controller: controller,
                                  maxLines: 2,
                                  minLines: 1,
                                  decoration: const InputDecoration(
                                      hintText: '如：請繳交給班長',
                                      hintStyle: TextStyle(height: 2),
                                      labelText: '其他提醒內容(選填)',
                                      helperText: '通知已包含名單，這裡只需要輸入其他的提醒內容！',
                                      helperStyle:
                                          TextStyle(color: Colors.red)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Fluttertoast.showToast(
                                    msg: '傳送中',
                                    timeInSecForIosWeb: 1,
                                    webShowClose: true,
                                  );
                                  Navigator.of(context).pop();
                                  ref.read(announceProvider.notifier).sendData(
                                        '${submitted.name}請於${submitted.date.toString().substring(0, 16)}前繳交，缺交名單：\n${numbersOfClass.where((e) => !submitted.done.contains(e.toString())).toList().join('、')}\n${controller.text}',
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('傳送'),
                              ),
                            ],
                          );
                        },
                      );
                    },
              icon: const Icon(Icons.announcement),
              tooltip: '發送繳交題提醒',
            ),
          )
        ],
      ),
      body: available
          ? ListView.builder(
              itemCount: numbersOfClass.length,
              itemBuilder: (context, idx) {
                bool checked =
                    submitted.done.contains('${numbersOfClass[idx]}');
                return CheckboxListTile(
                    title: Text(
                      '${numbersOfClass[idx]}號 ${usersNumber[numbersOfClass[idx].toString()] ?? ''}',
                      style: TextStyle(
                          color: usersNumber[numbersOfClass[idx].toString()] ==
                                  (ref.watch(authProvider).user!.displayName ??
                                      '')
                              ? (checked ? Colors.green : Colors.red)
                              : null),
                    ),
                    value: checked,
                    onChanged: (value) {
                      if (submitted.userId ==
                          ref.watch(authProvider).user!.uid) {
                        submitted.update('${numbersOfClass[idx]}');
                      }
                    });
              },
            )
          : const Center(
              child: Text('發生錯誤！'),
            ),
    );
  }
}

class HomeAnnounceBody extends ConsumerWidget {
  const HomeAnnounceBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();

    AnnounceState announceState = ref.watch(announceProvider);
    Map<String, String> usersData = ref.watch(usersProvider);

    ref.listen(announceProvider, (previous, next) {
      if (next.announces.isNotEmpty) {
        ref
            .read(announceReadProvider.notifier)
            .readMsg(next.announces.first.announceId);
      }
    });

    return LoadingView(
      loading: announceState.loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              physics: const BouncingScrollPhysics(),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                reverse: true,
                itemCount: announceState.announces.length,
                itemBuilder: (context, idx) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 40,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Text(usersData[
                                      announceState.announces[idx].userId] ??
                                  '未知建立者'),
                            ),
                            Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Linkify(
                                  onOpen: (link) async => openUrl(link.url),
                                  text: announceState.announces[idx].content,
                                  style: const TextStyle(fontSize: 18),
                                  linkStyle: const TextStyle(
                                      fontSize: 18, color: Colors.blue),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Text(
                        announceState.announces[idx].dateTime
                            .toString()
                            .substring(0, 16)
                            .replaceAll(' ', '\n'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ColoredBox(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: TextField(
                    maxLines: 2,
                    minLines: 1,
                    maxLength: 100,
                    controller: controller,
                    readOnly: ref.watch(authProvider).user!.isAnonymous,
                    decoration: InputDecoration(
                      labelText: ref.watch(authProvider).user!.isAnonymous
                          ? '您沒有權限'
                          : '要公告的內容',
                      hintText: '如：記得帶視力回條',
                      border: const OutlineInputBorder(),
                      counter: const SizedBox(),
                    ),
                  )),
                  const SizedBox(
                    width: 20,
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(),
                    onPressed: ref.watch(authProvider).user!.isAnonymous
                        ? null
                        : () {
                            if (controller.text.isNotEmpty) {
                              ref
                                  .read(announceProvider.notifier)
                                  .sendData(controller.text);
                              controller.text = '';
                            }
                          },
                    icon: const Icon(Icons.send),
                    label: const Text('公告'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TaskTableView extends ConsumerWidget {
  const TaskTableView(this.tasks, {super.key});
  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Table(
          border: TableBorder.all(color: Colors.blue, width: 2),
          children: [
            TableRow(children: [
              for (int d = 0; d < 5; d++)
                Builder(builder: (context) {
                  DateTime today = ref.watch(dateProvider).now;
                  DateTime date =
                      ref.watch(dateProvider).sunday.add(Duration(days: d + 1));
                  bool isToday = false;
                  if (date.isBefore(today) &&
                      date.add(const Duration(days: 1)).isAfter(today)) {
                    isToday = true;
                  }
                  int month = date.month;
                  int day = date.day;
                  return Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: Text(
                      '$month/$day',
                      style: TextStyle(
                        fontSize: isToday ? 18 : 15,
                        color: isToday ? Colors.blue : null,
                        fontWeight: isToday ? FontWeight.bold : null,
                      ),
                    ),
                  );
                }),
            ]),
            for (int l = 0; l < 7; l++)
              TableRow(
                  decoration: l == 3
                      ? const BoxDecoration(
                          border: Border(
                          bottom: BorderSide(
                              width: 5,
                              color: Colors.blue,
                              strokeAlign: BorderSide.strokeAlignInside),
                        ))
                      : null,
                  children: [
                    for (int d = 0; d < 5; d++)
                      Container(
                        margin:
                            l == 3 ? const EdgeInsets.only(bottom: 5) : null,
                        color: classColor(d + 1, l, tasks, Theme.of(context)),
                        height: 60,
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                                showDragHandle: true,
                                context: context,
                                builder: (context) => BottomSheet(
                                    className: lesson[d * 7 + l],
                                    weekDay: d + 1,
                                    lessonIdx: l));
                          },
                          child: Text(
                            lesson[d * 7 + l],
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ]),
          ]),
    );
  }

  Color? classColor(
      int weekDay, int lessonIdx, List<Task> tasks, ThemeData themeData) {
    int counter = 0;
    for (Task task in tasks) {
      if (task.classTime == lessonIdx && task.date.weekday == weekDay) {
        counter++;
      }
    }
    switch (counter) {
      case 0:
        return null;
      case 1:
        return themeData.colorScheme.tertiaryContainer;
      case 2:
        return themeData.colorScheme.secondaryContainer;
    }
    return themeData.colorScheme.primaryContainer;
  }
}

class TaskListView extends ConsumerWidget {
  const TaskListView(this.tasks,
      {this.showDateTitle = false,
      this.canScroll = true,
      this.short = false,
      super.key});

  final bool showDateTitle;
  final bool canScroll;
  final bool short;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderRadius = BorderRadius.circular(10);
    Map<String, String> usersData = ref.watch(usersProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        shape: BeveledRectangleBorder(borderRadius: borderRadius),
        child: ListView.builder(
          physics: canScroll
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          shrinkWrap: !canScroll,
          itemCount: tasks.length * 2,
          itemBuilder: (context, allIndex) {
            int idx = allIndex ~/ 2;
            if (allIndex % 2 == 1) {
              String lessonName = tasks[idx].classTime == -1
                  ? tasks[idx].date.toString().split(' ')[1].substring(0, 5)
                  : '第${tasks[idx].classTime + 1}節 ${lesson[(tasks[idx].date.weekday - 1) * 7 + tasks[idx].classTime]}';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Checkbox(
                        value:
                            ref.watch(todoProvider).contains(tasks[idx].taskId),
                        onChanged: (value) {
                          ref
                              .read(todoProvider.notifier)
                              .changeData(tasks[idx].taskId);
                        },
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 5,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              if (tasks[idx].top)
                                const Icon(
                                  Icons.push_pin,
                                  color: Colors.red,
                                  size: 25,
                                ),
                              Text(
                                tasks[idx].name,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (!short)
                            Text(
                              '$lessonName ${[
                                '考試',
                                '作業',
                                '報告',
                                '提醒',
                                '繳交',
                              ][tasks[idx].type]}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          if (!short)
                            Text(
                              usersData[tasks[idx].userId] ?? '未知建立者',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: PopupMenuButton(
                        itemBuilder: (context) => <PopupMenuEntry>[
                          PopupMenuItem(
                              enabled: tasks[idx].userId ==
                                  ref.watch(authProvider).user?.uid,
                              value: 'top',
                              child: Row(
                                children: [
                                  Icon(tasks[idx].top
                                      ? Icons.push_pin_outlined
                                      : Icons.push_pin),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(tasks[idx].top ? '取消置頂' : '置頂'),
                                ],
                              )),
                          const PopupMenuItem(
                              value: 'copy',
                              child: Row(
                                children: [
                                  Icon(Icons.copy),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('複製項目'),
                                ],
                              )),
                          const PopupMenuItem(
                              enabled: false,
                              value: 'star',
                              child: Row(
                                children: [
                                  Icon(Icons.star),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('標記星號'),
                                ],
                              )),
                          PopupMenuItem(
                              enabled: tasks[idx].userId ==
                                  ref.watch(authProvider).user?.uid,
                              value: 'edit',
                              child: const Row(
                                children: [
                                  Icon(Icons.edit_note),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('修改'),
                                ],
                              )),
                        ],
                        onSelected: (value) async {
                          switch (value) {
                            case 'top':
                              tasks[idx].pinTop();
                              break;
                            case 'edit':
                              ref
                                  .read(formProvider.notifier)
                                  .startUpdate(tasks[idx]);
                              showDialog(
                                context: context,
                                builder: (context) => const TaskForm(),
                              );
                              break;
                            case 'star':
                              break;
                            case 'copy':
                              await Clipboard.setData(
                                  ClipboardData(text: tasks[idx].name));
                              Fluttertoast.showToast(
                                msg: '已複製到剪貼簿',
                                timeInSecForIosWeb: 1,
                                webShowClose: true,
                              );
                              break;
                          }
                        },
                        tooltip: '更多',
                      ),
                    ),
                  ],
                ),
              );
            } else {
              if ((idx == 0
                      ? true
                      : tasks[idx].date.day != tasks[idx - 1].date.day) &&
                  showDateTitle) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: borderRadius,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: EdgeInsets.only(top: (idx == 0) ? 0 : 8, bottom: 8),
                  child: Text('${tasks[idx].date.toString().split(' ')[0]}  週${[
                    '日',
                    'ㄧ',
                    '二',
                    '三',
                    '四',
                    '五',
                    '六'
                  ][tasks[idx].date.weekday % 7]}'),
                );
              } else if (idx != 0) {
                return const Divider();
              } else {
                return const SizedBox();
              }
            }
          },
        ),
      ),
    );
  }
}

class TaskForm extends ConsumerStatefulWidget {
  const TaskForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = ref.read(formProvider).name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(ref.watch(formProvider).formStatus == TaskFormStatus.create
              ? '新增項目'
              : '修改項目'),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(formProvider.notifier).editFinish();
              },
              icon: const Icon(Icons.close))
        ],
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '請輸入完整，如：英文U1單字',
                  hintStyle: TextStyle(height: 2),
                  labelText: '項目名稱',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 2) {
                    return '請輸入項目名稱';
                  }
                  return null;
                },
                onChanged: (value) =>
                    ref.read(formProvider.notifier).nameChange(value),
              ),
              DropdownButton<int>(
                  value: ref.watch(formProvider).type,
                  onChanged: (int? value) =>
                      ref.read(formProvider.notifier).typeChange(value!),
                  items: const [
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text('考試'),
                    ),
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('作業'),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text('報告'),
                    ),
                    DropdownMenuItem<int>(
                      value: 3,
                      child: Text('提醒'),
                    ),
                    DropdownMenuItem<int>(
                      value: 4,
                      child: Text('繳交'),
                    ),
                  ]),
              const Padding(
                padding: EdgeInsets.only(top: 2, bottom: 8),
                child: Text(
                  '需清點繳交物品請由「幹部」選擇繳交',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: ref
                                      .read(formProvider)
                                      .date
                                      .isBefore(DateTime.now())
                                  ? DateTime.now()
                                  : ref.read(formProvider).date,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 150)))
                          .then((DateTime? dateTime) => ref
                              .read(formProvider.notifier)
                              .dateChange(dateTime!));
                    },
                    style: TextButton.styleFrom(),
                    child: Text(
                      ref.watch(formProvider).date.toString().split(' ')[0],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(ref.read(formProvider).date),
                      ).then((TimeOfDay? time) =>
                          ref.read(formProvider.notifier).timeChange(time!));
                    },
                    style: TextButton.styleFrom(),
                    child: Text(
                      ref
                          .watch(formProvider)
                          .date
                          .toString()
                          .split(' ')[1]
                          .split('.')[0],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (ref.watch(formProvider).formStatus == TaskFormStatus.create)
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Fluttertoast.showToast(
                  msg: '建立資料中',
                  timeInSecForIosWeb: 1,
                  webShowClose: true,
                );
                Navigator.of(context).pop();
                ref.read(formProvider.notifier).create();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('建立'),
          ),
        if (ref.watch(formProvider).formStatus == TaskFormStatus.update)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Fluttertoast.showToast(
                      msg: '更新資料中',
                      timeInSecForIosWeb: 1,
                      webShowClose: true,
                    );
                    Navigator.of(context).pop();
                    ref.read(formProvider.notifier).update();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('更新'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onLongPress: () async {
                  if (_formKey.currentState!.validate()) {
                    Fluttertoast.showToast(
                      msg: '刪除資料中',
                      timeInSecForIosWeb: 1,
                      webShowClose: true,
                    );
                    Navigator.of(context).pop();
                    ref.read(formProvider.notifier).remove();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: null,
                child: const Text('長按刪除'),
              ),
            ],
          ),
      ],
    );
  }
}

class BottomSheet extends ConsumerWidget {
  const BottomSheet(
      {required this.className,
      required this.weekDay,
      required this.lessonIdx,
      super.key});
  final String className;
  final int weekDay;
  final int lessonIdx;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TaskState taskState = ref.watch(taskProvider);
    List<Task> tasks = taskState.tasks;
    List<Task> tasksForThisClass = [];
    for (Task task in tasks) {
      if (task.classTime == lessonIdx && task.date.weekday == weekDay) {
        tasksForThisClass.add(task);
      }
    }

    DateTime date =
        ref.watch(dateProvider).sunday.add(Duration(days: weekDay)).copyWith(
              hour: classTimes[lessonIdx].hour,
              minute: classTimes[lessonIdx].minute,
              second: 0,
            );

    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.month}/${date.day} 第${lessonIdx + 1}節 $className',
                  style: const TextStyle(fontSize: 22.5),
                ),
                if (!ref.watch(authProvider).user!.isAnonymous)
                  IconButton(
                    onPressed: ref.watch(nowTimeProvider).isBefore(date)
                        ? () {
                            ref.read(formProvider.notifier).dateChange(date);
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    const TaskForm());
                          }
                        : null,
                    icon: const Icon(Icons.add_task),
                    tooltip: '新增事項在這一節課',
                  ),
              ],
            ),
          ),
          Expanded(
            child: TaskListView(tasksForThisClass),
          ),
        ],
      ),
    );
  }
}

// class HomeFileView extends ConsumerWidget {
//   const HomeFileView({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     FileState state = ref.watch(fileProvider);
//     return LoadingView(
//       loading: state.loading,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: RefreshIndicator(
//           onRefresh: () => ref.read(fileProvider.notifier).getFilesList(),
//           child: GridView.builder(
//             physics: const AlwaysScrollableScrollPhysics(),
//             itemCount: state.files.length,
//             gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//               maxCrossAxisExtent: 250,
//             ),
//             itemBuilder: (context, idx) => Padding(
//               padding: const EdgeInsets.all(5),
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 5),
//                   child: FutureBuilder(
//                       future: state.files[idx].getDownloadURL(),
//                       builder: (context, snap) {
//                         return InkWell(
//                           onTap: () async {
//                             if (['.png', '.jpg', '.jpeg', '.webp'].any(
//                                 (element) =>
//                                     state.files[idx].name.contains(element))) {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                     builder: (context) => PhotoViewer(
//                                         state.files[idx].name.substring(24),
//                                         snap.data ?? '')),
//                               );
//                             } else {
//                               openUrl(snap.data ?? '');
//                             }
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 5),
//                             child: Column(
//                               children: [
//                                 Expanded(child: Builder(builder: (context) {
//                                   if (['.png', '.jpg', '.jpeg', '.webp'].any(
//                                       (element) => state.files[idx].name
//                                           .contains(element))) {
//                                     return Builder(builder: (context) {
//                                       if (snap.hasData) {
//                                         return Image.network(
//                                           snap.data ?? '',
//                                           fit: BoxFit.cover,
//                                         );
//                                       } else {
//                                         return const Icon(
//                                           Icons.photo,
//                                           size: 100,
//                                         );
//                                       }
//                                     });
//                                   } else {
//                                     return const Icon(
//                                       Icons.file_open,
//                                       size: 100,
//                                     );
//                                   }
//                                 })),
//                                 Text(
//                                   state.files[idx].name.substring(24),
//                                   maxLines: 2,
//                                   style: const TextStyle(fontSize: 18),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PhotoViewer extends ConsumerWidget {
//   const PhotoViewer(this.name, this.url, {super.key});

//   final String name;
//   final String url;
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           name,
//           style: const TextStyle(fontSize: 15),
//         ),
//       ),
//       body: PhotoView(imageProvider: NetworkImage(url)),
//     );
//   }
// }
