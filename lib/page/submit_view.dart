import 'dart:ui';

import 'package:class_todo_list/logic/submit_notifier.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class HomeSubmittedBody extends ConsumerWidget {
  const HomeSubmittedBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, String> usersNumber = ref.watch(usersNumberProvider);
    SubmittedState submittedState = ref.watch(submittedProvider);
    Map<String, String> usersData = ref.watch(usersProvider);
    return LoadingView(
        loading: submittedState.loading,
        child: Builder(builder: (context) {
          if (submittedState.submittedItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.blue,
                    size: 50,
                  ),
                  Text('目前沒有繳交項目')
                ],
              ),
            );
          } else {
            return ListView.separated(
              itemCount: submittedState.submittedItems.length,
              itemBuilder: (context, idx) {
                Submitted submitted = submittedState.submittedItems[idx];
                bool done =
                    submitted.done.contains(ref.watch(selfNumberProvider));
                return Card(
                  clipBehavior: Clip.hardEdge,
                  margin: submittedState.submittedItems.length == 1
                      ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                      : idx == 0
                          ? const EdgeInsets.fromLTRB(20, 10, 20, 0)
                          : idx == submittedState.submittedItems.length - 1
                              ? const EdgeInsets.fromLTRB(20, 0, 20, 10)
                              : const EdgeInsets.symmetric(horizontal: 20),
                  shape: submittedState.submittedItems.length == 1
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25))
                      : idx == 0
                          ? const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25)))
                          : idx == submittedState.submittedItems.length - 1
                              ? const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(25),
                                      bottomRight: Radius.circular(25)))
                              : const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                  child: ListTile(
                    leading: Icon(Icons.text_snippet_outlined,
                        color: done ||
                                !usersNumber.values
                                    .contains(ref.watch(selfNumberProvider))
                            ? null
                            : Colors.red),
                    title: Text(
                      '${submitted.name} ${submitted.done.length}/${usersNumber.keys.length}',
                      style: TextStyle(
                          color: done ||
                                  !usersNumber.values
                                      .contains(ref.watch(selfNumberProvider))
                              ? null
                              : Colors.red),
                    ),
                    subtitle: Wrap(
                      spacing: 5,
                      children: [
                        Text(usersData[submitted.userId] ?? '未知使用者'),
                        Text(
                            '截止日期：${DateFormat('yyyy/MM/dd EE HH:mm', 'zh-TW').format(submitted.date)}'),
                      ],
                    ),
                    trailing: !usersNumber.keys
                            .contains(ref.watch(selfNumberProvider))
                        ? null
                        : Text(
                            done ? '已繳交' : '缺交',
                            style: TextStyle(
                                fontSize: 15,
                                color: done ? Colors.green : Colors.red),
                          ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            SubmittedDone(submitted.submittedId))),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                height: 0,
                indent: 70,
                endIndent: 20,
              ),
            );
          }
        }));
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
          '${submitted.name} ${submitted.done.length}/${usersNumber.keys.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController controller = TextEditingController();
                    return SimpleDialog(
                      contentPadding: const EdgeInsets.all(20),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('分享繳交列表'),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                ref.read(formProvider.notifier).editFinish();
                              },
                              icon: const Icon(Icons.close))
                        ],
                      ),
                      children: [
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            selectionHeightStyle: BoxHeightStyle.strut,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            controller: controller,
                            maxLines: 2,
                            minLines: 1,
                            decoration: const InputDecoration(
                                hintText: '如：請繳交給班長',
                                hintStyle: TextStyle(height: 2),
                                labelText: '其他提醒內容(選填)',
                                helperText: '通知已包含名單，不需要手動輸入！',
                                helperStyle: TextStyle(color: Colors.red)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () {
                            Share.share(
                              '''${submitted.name}請於${DateFormat('yyyy/MM/dd EEEE HH:mm', 'zh-TW').format(submitted.date)}前繳交，缺交名單：
${usersNumber.keys.where((e) => !submitted.done.contains(e)).toList().join('、')}
${controller.text}''',
                            ).then((v) {
                              if (v.status == ShareResultStatus.success &&
                                  context.mounted) {
                                Navigator.of(context).pop();
                              }
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                          child: const Text('分享'),
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
              itemCount: usersNumber.keys.length,
              itemBuilder: (context, idx) {
                String key = usersNumber.keys.toList()[idx];
                bool checked = submitted.done.contains(key);
                return CheckboxListTile(
                    title: Text(
                      '$key號 ${usersNumber[key] ?? ''}',
                      style: TextStyle(
                          color: key == (ref.watch(selfNumberProvider))
                              ? (checked ? Colors.green : Colors.red)
                              : null),
                    ),
                    value: checked,
                    onChanged: (value) {
                      if (submitted.userId ==
                          ref.watch(authProvider).user!.uid) {
                        HapticFeedback.lightImpact();
                        submitted.update(key, ref);
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
