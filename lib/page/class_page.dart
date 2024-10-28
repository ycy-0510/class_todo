import 'dart:ui';

import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassesPage extends ConsumerWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool loading = ref.watch(authProvider).loading;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: 400,
            height: 500,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  if (loading) const LinearProgressIndicator(),
                  const Expanded(child: SizedBox()),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Text(
                      '請輸入課程代碼和序號',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                    '目前登入帳號：${ref.watch(authProvider).user?.displayName}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: JoinClassForm(),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: '你的班級尚未加入這個app嗎？ ',
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: <TextSpan>[
                          TextSpan(
                              text: '前往官網',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => openUrl(
                                    'https://classtodo.ycydev.org/home#h.lnjtm8ihgxy1')),
                          const TextSpan(text: '申請加入吧！'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        '不是你的帳號嗎？',
                        style: TextStyle(fontSize: 18),
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () => ref.read(authProvider.notifier).logout(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                        ),
                        child: const Text(
                          '登出',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text(
                        'Copyright © 2024 YCY, Licensed under the Apache License, Version 2.0.'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class JoinClassForm extends ConsumerStatefulWidget {
  const JoinClassForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _JoinClassFormState();
}

class _JoinClassFormState extends ConsumerState<JoinClassForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _classCodecontroller = TextEditingController();
  final TextEditingController _serialCodecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool loading = ref.watch(authProvider).loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: TextFormField(
                      selectionHeightStyle: BoxHeightStyle.strut,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      controller: _classCodecontroller,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 5) {
                          return '請輸入正確班級代碼';
                        }
                        return null;
                      },
                      readOnly: loading,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.class_outlined),
                          labelText: '請輸入班級代碼',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: TextFormField(
                      selectionHeightStyle: BoxHeightStyle.strut,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      controller: _serialCodecontroller,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 10) {
                          return '請輸入正確班級序號';
                        }
                        return null;
                      },
                      readOnly: loading,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.password),
                          labelText: '請輸入班級序號',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                  ),
                ])),
        ElevatedButton(
          onPressed: loading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    ref.read(authProvider.notifier).joinClass(
                        _classCodecontroller.text, _serialCodecontroller.text);
                    _serialCodecontroller.clear();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            '加入班級',
            style: TextStyle(fontSize: 18),
          ),
        )
      ],
    );
  }
}
