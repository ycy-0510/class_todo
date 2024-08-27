import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                        const SizedBox(
                            width: 100,
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
                            child: const Text('更新課表'),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                      '上次更新課表：${DateFormat('yyyy-MM-dd hh:mm').format(ref.watch(classTableProvider).lastUpdate)}'),
                  const SizedBox(
                    height: 10,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: 100,
                            child: Text(
                              '座號',
                              style: TextStyle(fontSize: 18),
                            )),
                        SizedBox(
                          width: 120,
                          child: SelfNumberField(),
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
                        const SizedBox(
                            width: 100,
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
        },
      ),
    );
  }
}
