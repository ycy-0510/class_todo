import 'dart:ui';

import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class DrawLotsPage extends ConsumerStatefulWidget {
  const DrawLotsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DrawLotsPageState();
}

class _DrawLotsPageState extends ConsumerState<DrawLotsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerGroup = TextEditingController(),
      _controllerPeople = TextEditingController();

  List<List<Student>> result = [];

  void drawlots() {
    List<Student> students = [];
    Map<String, String> studentData = ref.read(usersNumberProvider);
    for (var entry in studentData.entries) {
      students.add(Student.fromMapEntry(entry));
    }
    students.shuffle();
    int group = int.parse(_controllerGroup.text);
    int people = int.parse(_controllerPeople.text);
    result = List.generate(group, (v) => <Student>[]);
    setState(() {
      for (int i = 0; i < people; i++) {
        for (int j = 0; j < group; j++) {
          if (students.isNotEmpty) {
            result[j].add(students.removeLast());
          } else {
            break;
          }
        }
      }
      for (int j = 0; j < group; j++) {
        result[j]
            .sort((a, b) => int.parse(a.number).compareTo(int.parse(b.number)));
      }
    });
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: const Text("已抽籤完成"),
      alignment: Alignment.topCenter,
      showProgressBar: false,
      autoCloseDuration: const Duration(milliseconds: 1500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('班級抽籤筒'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          selectionHeightStyle: BoxHeightStyle.strut,
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          controller: _controllerGroup,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: '組別數',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefix: const Text('共'),
                            suffix: const Text('組'),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{1,3}$')),
                          ],
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return '請輸入組數';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          selectionHeightStyle: BoxHeightStyle.strut,
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          controller: _controllerPeople,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: '人數',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefix: const Text('每組'),
                            suffix: const Text('人'),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{1,3}$')),
                          ],
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return '請輸入人數';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('若只要抽籤，請輸入於組別數，每組人數填0。'),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      drawlots();
                    }
                  },
                  child: const Text('抽籤/分組'),
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: result.length,
            itemBuilder: (context, idx) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        '第${idx + 1}組',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        result[idx].fold(
                            '',
                            (prev, curr) =>
                                prev +
                                (prev.isNotEmpty ? ' ' : '') +
                                curr.number),
                        style: const TextStyle(
                            fontSize: 16, overflow: TextOverflow.visible),
                      )
                    ],
                  ),
                ),
              );
            },
          ))
        ],
      ),
    );
  }
}

class Student {
  String number;
  String name;
  Student(this.number, this.name);
  factory Student.fromMapEntry(MapEntry<String, String> entry) {
    return Student(entry.key, entry.value);
  }
}
