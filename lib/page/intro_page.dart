import 'package:class_todo_list/logic/notification_notifier.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class IntroPage extends ConsumerStatefulWidget {
  const IntroPage({super.key});

  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends ConsumerState<IntroPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    Navigator.of(context).pop();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('intro', true);
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.asset('assets/img/intro/$assetName', width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      allowImplicitScrolling: true,
      pages: [
        PageViewModel(
          title: "記錄班上的考試、作業",
          body: "只要隨手記下，不用再每天回想有哪些考試或作業。",
          image: _buildImage('intro-task.jpg'),
          decoration: pageDecoration,
          useRowInLandscape: true,
        ),
        PageViewModel(
          title: "輕鬆清點班上事務",
          body: "透過清點功能，你可以在同學繳交時登記，直接分享缺交名單到班群。",
          image: _buildImage('intro-submit.jpg'),
          decoration: pageDecoration,
          useRowInLandscape: true,
        ),
        PageViewModel(
          title: "即時掌握校園公告",
          body: "在app內直接瀏覽最新公告並標記已讀，不用開啟學校網站也不怕漏看。",
          image: _buildImage('intro-schoolannounce.jpg'),
          decoration: pageDecoration,
          useRowInLandscape: true,
        ),
        PageViewModel(
          title: "共享好處多",
          body: "透過共享，平均每人可減少60%時間管理學校待辦事項。",
          image: _buildImage('intro-sharing.jpg'),
          decoration: pageDecoration,
          useRowInLandscape: true,
        ),
        PageViewModel(
          title: "更多功能等你來使用",
          body: "這裡還有其他附加功能，例如：班級名單、抽籤分組等。",
          image: _buildImage('intro-morefeatures.jpg'),
          decoration: pageDecoration,
          useRowInLandscape: true,
        ),
        PageViewModel(
          title: "使用後發現功能不夠嗎？",
          body: "你可以使用app內的意見回饋或傳送mail，我們樂意聆聽你的想法。",
          image: _buildImage('intro-feedbacks.jpg'),
          decoration: pageDecoration,
          useRowInLandscape: true,
        ),
        PageViewModel(
          title: "最重要的，開啟通知",
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "開啟通知可以讓你在每天固定時間，得知24小時內的事項，不怕考試前才想到。",
                style: bodyStyle,
              ),
              const SizedBox(
                height: 80,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: ElevatedButton(
                  onPressed: () {
                    switch (
                        ref.read(notificationProvider).authorizationStatus) {
                      case NotificationAuthorizationStatus.authorized:
                        toastification.show(
                          type: ToastificationType.info,
                          style: ToastificationStyle.flatColored,
                          title: const Text("你已成功啟用通知"),
                          alignment: Alignment.topCenter,
                          showProgressBar: false,
                          autoCloseDuration: const Duration(milliseconds: 1500),
                        );
                        _onIntroEnd(context);
                        break;
                      case NotificationAuthorizationStatus.appDenied:
                      case NotificationAuthorizationStatus.notDetermined:
                        ref
                            .read(notificationProvider.notifier)
                            .openBottomSheet();
                        break;
                      case NotificationAuthorizationStatus.systemDenied:
                        openAppSettings();
                        break;
                    }
                  },
                  child: const Text(
                    '開啟通知',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
          image: _buildImage('intro-notification.jpg'),
          decoration: pageDecoration,
          useRowInLandscape: true,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => introKey.currentState?.skipToEnd(),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      back: const Icon(Icons.arrow_back),
      skip: const Text('跳過', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('完成', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        activeColor: Colors.blue,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
