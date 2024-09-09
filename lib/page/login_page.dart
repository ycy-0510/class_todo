import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final controller = PageController(initialPage: 0);

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

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
                      '歡迎使用「共享聯絡簿」',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const Icon(
                    Icons.login,
                    size: 100,
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: 300,
                      height: 45,
                      child: ElevatedButton.icon(
                        onLongPress: loading ? null : () {},
                        onPressed: loading
                            ? null
                            : () =>
                                ref.read(authProvider.notifier).googleLogin(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                        ),
                        label: const Text(
                          '使用Google登入',
                          style: TextStyle(fontSize: 18),
                        ),
                      )),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    width: 300,
                    height: 45,
                    child: ElevatedButton.icon(
                      onLongPress: loading ? null : () {},
                      onPressed: loading
                          ? null
                          : () => ref.read(authProvider.notifier).appleLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      icon: const FaIcon(FontAwesomeIcons.apple),
                      label: const Text(
                        '使用Apple登入',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          text: '登入即表示您同意我們的',
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: <TextSpan>[
                            TextSpan(
                                text: '隱私政策',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => openUrl(
                                      'https://classtodo.ycydev.org/privacypolicy')),
                            const TextSpan(text: '。'),
                          ],
                        ),
                      )),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text(
                        'Copyright © 2024 YCY, Licensed under the Apache License, Version 2.0.'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
