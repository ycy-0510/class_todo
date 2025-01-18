import 'package:class_todo_list/adaptive_action.dart';
import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tawk_to_chat/flutter_tawk_to_chat.dart';

class SupportPage extends ConsumerStatefulWidget {
  const SupportPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SupportPageState();
}

class _SupportPageState extends ConsumerState<SupportPage> {
  TawkController? _controller;
  @override
  Widget build(BuildContext context) {
    User? user = ref.watch(authProvider).user;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        } else {
          if (_controller == null) {
            Navigator.of(context).pop();
          } else if (await _controller!.canGoBack()) {
            _controller!.goBack();
          } else if (await _controller!.isChatOngoing() && context.mounted) {
            bool? result = await showAdaptiveDialog<bool>(
              context: context,
              builder: (context) => AlertDialog.adaptive(
                title: const Text('是否離開線上支援'),
                content: const Text('離開線上支援後，正在進行的對話將自動結束。'),
                actions: [
                  AdaptiveAction(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      danger: true,
                      child: const Text('離開')),
                  AdaptiveAction(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('取消'))
                ],
              ),
            );
            if (result == true && context.mounted) {
              _controller?.endChat();
              Navigator.of(context).pop();
            }
          } else if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('線上支援'),
        ),
        body: LoadingView(
          loading: false,
          child: Tawk(
            directChatLink:
                'https://tawk.to/chat/6783c71baf5bfec1dbea79fa/1ihdc3hee',
            onLinkTap: (url) => openUrl(url),
            placeholder: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
            visitor: user != null
                ? TawkVisitor(
                    name: user.displayName,
                    email: user.email,
                  )
                : null,
            onControllerChanged: (controller) {
              _controller = controller;
            },
          ),
        ),
      ),
    );
  }
}
