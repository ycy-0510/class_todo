import 'package:class_todo_list/logic/submit_notifier.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
              (k) => usersNumber[k] == ref.watch(selfNumberProvider),
              orElse: () => ''));
          return ListTile(
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
                Text('截止日期：${submitted.date.toString().substring(0, 16)}'),
              ],
            ),
            trailing:
                !usersNumber.values.contains(ref.watch(selfNumberProvider))
                    ? null
                    : Text(
                        done ? '已繳交' : '缺交',
                        style: TextStyle(
                            fontSize: 15,
                            color: done ? Colors.green : Colors.red),
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
          '${submitted.name} ${submitted.done.length}/${usersNumber.keys.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: submitted.userId != ref.watch(authProvider).user!.uid
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
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
                                        '${submitted.name}請於${submitted.date.toString().substring(0, 16)}前繳交，缺交名單：\n${usersNumber.keys.where((e) => !submitted.done.contains(e)).toList().join('、')}\n${controller.text}',
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
              itemCount: usersNumber.keys.length,
              itemBuilder: (context, idx) {
                String key = usersNumber.keys.toList()[idx];
                bool checked = submitted.done.contains('${usersNumber[key]}');
                return CheckboxListTile(
                    title: Text(
                      '$key號 ${usersNumber[key] ?? ''}',
                      style: TextStyle(
                          color: usersNumber[key] ==
                                  (ref.watch(selfNumberProvider))
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
