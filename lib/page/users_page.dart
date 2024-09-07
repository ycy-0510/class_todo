import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, String> usersData = ref.watch(usersProvider);
    Map<String, String> studentData = ref.watch(usersNumberProvider);
    List<String> userNames = usersData.values.toList()..sort();
    String selfNumber = ref.watch(selfNumberProvider);
    UsersType usersTypeState = ref.watch(usersTypeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('成員'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SegmentedButton<UsersType>(
                segments: const <ButtonSegment<UsersType>>[
                  ButtonSegment<UsersType>(
                      value: UsersType.users,
                      label: Text('已加入使用者'),
                      icon: Icon(Icons.person)),
                  ButtonSegment<UsersType>(
                      value: UsersType.students,
                      label: Text('班級名單'),
                      icon: FaIcon(FontAwesomeIcons.graduationCap)),
                ],
                selected: <UsersType>{
                  usersTypeState
                },
                onSelectionChanged: (Set<UsersType> newSelection) {
                  HapticFeedback.lightImpact();
                  ref
                      .read(usersTypeProvider.notifier)
                      .update((state) => newSelection.first);
                }),
            Builder(builder: (context) {
              switch (usersTypeState) {
                case UsersType.users:
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: usersData.keys.length,
                    itemBuilder: (context, idx) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(userNames[idx]),
                    ),
                  );
                case UsersType.students:
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: studentData.keys.length,
                    itemBuilder: (context, idx) {
                      String key = studentData.keys.toList()[idx];
                      return ListTile(
                        leading: const FaIcon(FontAwesomeIcons.graduationCap),
                        title: Text(
                          '$key號 ${studentData[key] ?? ''}',
                        ),
                        textColor: key == selfNumber ? Colors.green : null,
                      );
                    },
                  );
              }
            }),
          ],
        ),
      ),
    );
  }
}
