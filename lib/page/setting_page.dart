import 'dart:ui';

import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('個人設定'),
        ),
        body: const SettingPageBody());
  }
}

class SettingPageBody extends ConsumerWidget {
  const SettingPageBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? classCode = ref.watch(authProvider).classCode;
    String? name = ref.watch(authProvider).user?.displayName ?? '';
    bool? linkedGoogle = ref.watch(googleApiProvider).loggedIn;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                            child: Text(
                          '班級',
                          style: TextStyle(fontSize: 18),
                        )),
                        SizedBox(
                            width: 120,
                            child: Text(
                              classCode ?? '無班級',
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                            width: 120,
                            child: Text(
                              '課表',
                              style: TextStyle(fontSize: 18),
                            )),
                        SizedBox(
                          width: 120,
                          child: OutlinedButton(
                            onPressed: ref
                                    .watch(classTableProvider)
                                    .lastUpdate
                                    .add(const Duration(hours: 2))
                                    .isAfter(ref.watch(nowTimeProvider))
                                ? null
                                : () {
                                    HapticFeedback.mediumImpact();
                                    ref
                                        .read(classTableProvider.notifier)
                                        .updateClassTable();
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                              foregroundColor: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .color,
                              side: BorderSide(color: Colors.grey.shade600),
                            ),
                            child: Text(ref
                                    .watch(classTableProvider)
                                    .lastUpdate
                                    .add(const Duration(hours: 2))
                                    .isAfter(ref.watch(nowTimeProvider))
                                ? '最近更新'
                                : '更新課表'),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          '座號',
                          style: TextStyle(fontSize: 18),
                        )),
                        Column(
                          children: [
                            SizedBox(
                              width: 120,
                              child: SelfNumberField(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                            child: Text(
                          '姓名',
                          style: TextStyle(fontSize: 18),
                        )),
                        Text(
                          name,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
                '''上次更新課表：${DateFormat('yyyy/MM/dd HH:mm', 'zh-TW').format(ref.watch(classTableProvider).lastUpdate)}。
輸入您的座號後，繳交列表方可顯示你是否缺交。'''),
          ),
          const SizedBox(
            height: 10,
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                            width: 120,
                            child: Text(
                              '通知時間',
                              style: TextStyle(fontSize: 18),
                            )),
                        SizedBox(
                          width: 120,
                          child: OutlinedButton(
                            onPressed: () {
                              DateTime? notificationTime = ref
                                  .read(notificationProvider)
                                  .notificationTime;
                              showTimePicker(
                                context: context,
                                initialTime: notificationTime != null
                                    ? TimeOfDay.fromDateTime(notificationTime)
                                    : const TimeOfDay(hour: 20, minute: 0),
                              ).then((time) {
                                if (time == null) return;
                                ref
                                    .read(notificationProvider.notifier)
                                    .setNotificationTime(time);
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                              foregroundColor: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .color,
                              side: BorderSide(color: Colors.grey.shade600),
                            ),
                            child: Builder(builder: (context) {
                              DateTime? notificationTime = ref
                                  .watch(notificationProvider)
                                  .notificationTime;
                              return Text(
                                notificationTime == null
                                    ? '尚未設定'
                                    : DateFormat('HH:mm')
                                        .format(notificationTime),
                              );
                            }),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text('''目前通知只能設為整點或30分。
你可以在「更多」頁面查看通知啟用狀態。'''),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                if (linkedGoogle) {
                  ref.read(googleApiProvider.notifier).unlink();
                } else {
                  ref.read(googleApiProvider.notifier).linkGoogle();
                }
              },
              icon: Icon(linkedGoogle ? Icons.link_off : Icons.link),
              label: Text(
                linkedGoogle ? '取消連接 Google 行事曆' : '連接 Google 行事曆',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text('''注意：目前通知尚未提供個人行事曆提醒功能。'''),
          ),
          const Divider(
            indent: 30,
            endIndent: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text(
                '登出帳號',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('刪除帳號'),
                    content: const Text('請注意：刪除帳號後將無法復原，是否要刪除帳號？'),
                    actions: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red)),
                        child: const Text('刪除'),
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
                  if (value == true && context.mounted) {
                    Navigator.of(context).pop();
                    ref.read(authProvider.notifier).deleteAccount();
                  }
                });
              },
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red)),
              icon: const Icon(Icons.delete_forever),
              label: const Text(
                '刪除帳號',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class SelfNumberField extends ConsumerStatefulWidget {
  const SelfNumberField({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelfNumberFieldState();
}

class _SelfNumberFieldState extends ConsumerState<SelfNumberField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = ref.read(selfNumberProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selfNumberProvider, (prev, next) {
      _controller.text = next;
    });

    return TextField(
      controller: _controller,
      selectionHeightStyle: BoxHeightStyle.strut,
      textAlign: TextAlign.center,
      onEditingComplete: () {
        FocusManager.instance.primaryFocus?.unfocus();
        HapticFeedback.mediumImpact();
        ref.read(selfNumberProvider.notifier).setNumber(_controller.text);
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: const Text("設定座號成功！"),
          description: Text("已設定為${_controller.text}號"),
          alignment: Alignment.topCenter,
          showProgressBar: false,
          autoCloseDuration: const Duration(milliseconds: 1500),
        );
      },
    );
  }
}
