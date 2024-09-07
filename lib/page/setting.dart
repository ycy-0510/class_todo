import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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
                          child: ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
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
                '''上次更新課表：${DateFormat('yyyy-MM-dd HH:mm').format(ref.watch(classTableProvider).lastUpdate)}。
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '學校RSS',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Icon(Icons.rss_feed),
                      ],
                    ),
                  ),
                  for (final item in ref.watch(rssUrlProvider).rssEndpoints)
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 18),
                            ))),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text('''RSS網址可以讓這個app擷取你的學校的最新訊息。'''),
          ),
          const SizedBox(
            height: 10,
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
                        ),
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
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.delete_forever),
              label: const Text(
                '刪除帳號',
                style: TextStyle(fontSize: 18),
              ),
            ),
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

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        onEditingComplete: () {
          FocusManager.instance.primaryFocus?.unfocus();
          HapticFeedback.mediumImpact();
          ref.read(selfNumberProvider.notifier).setNumber(_controller.text);
          Fluttertoast.showToast(msg: '設定座號成功！');
        },
      ),
    );
  }
}
