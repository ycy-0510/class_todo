import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 200, child: Image.asset('assets/img/icon.png')),
          const Text(
            '載入中...',
            style: TextStyle(fontSize: 18),
          )
        ],
      )),
    );
  }
}
