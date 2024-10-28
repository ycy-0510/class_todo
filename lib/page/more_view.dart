import 'package:class_todo_list/logic/notification_notifier.dart';
import 'package:class_todo_list/open_url.dart';
import 'package:class_todo_list/page/draw_lots.dart';
import 'package:class_todo_list/page/intro_page.dart';
import 'package:class_todo_list/page/setting_page.dart';
import 'package:class_todo_list/page/users_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:feedback_sentry/feedback_sentry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

class HomeMoreBody extends ConsumerWidget {
  const HomeMoreBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? classCode = ref.watch(authProvider).classCode;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingPage())),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: ColoredBox(
                          color: Colors.blueGrey,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                              height: 60,
                              width: 60,
                              child: Center(
                                child: Text(
                                  (ref
                                          .watch(authProvider)
                                          .user
                                          ?.displayName
                                          ?.toUpperCase() ??
                                      '訪客')[0],
                                  style: const TextStyle(
                                      fontSize: 30, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            ref.watch(authProvider).user?.displayName ?? '訪客',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            '查看及設定個人資料',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Card(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Column(
                children: [
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const FaIcon(FontAwesomeIcons.school),
                    title: const Text('班級代碼'),
                    trailing: Text(
                      classCode ?? '無班級',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const Icon(Icons.people),
                    title: const Text('班級成員'),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const UsersPage())),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const FaIcon(FontAwesomeIcons.dice),
                    title: const Text('抽籤分組'),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const DrawLotsPage())),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              )),
          const SizedBox(
            height: 10,
          ),
          Card(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Column(
                children: [
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const Icon(Icons.info),
                    title: const Text('關於這個app'),
                    onTap: () {
                      showAboutDialog(
                          context: context,
                          applicationName: '共享聯絡簿',
                          applicationIcon: Image.asset(
                            'assets/img/icon.png',
                            height: 70,
                          ),
                          applicationLegalese:
                              'Copyright © 2024 YCY, Licensed under the Apache License, Version 2.0.');
                    },
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const Icon(Icons.app_shortcut),
                    title: const Text('app介紹'),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const IntroPage())),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const Icon(Icons.feedback),
                    title: const Text('回饋意見'),
                    onTap: () =>
                        BetterFeedback.of(context).showAndUploadToSentry(
                      name: ref.read(authProvider).user?.displayName,
                      email: ref.read(authProvider).user?.email,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const Icon(Icons.web),
                    title: const Text('官方網頁'),
                    onTap: () => openUrl('https://classtodo.ycydev.org'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const FaIcon(FontAwesomeIcons.dev),
                    title: const Text('開發者網頁'),
                    onTap: () =>
                        openUrl('https://sites.google.com/view/ycyprogram'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const Icon(Icons.chat),
                    title: const Text('線上支援'),
                    onTap: () => openUrl('https://tawk.to/ycyprogram'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const Icon(Icons.code),
                    title: const Text('開放原始碼'),
                    onTap: () =>
                        openUrl('https://github.com/ycy-0510/class_todo'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                    minLeadingWidth: 30,
                    leading: const Icon(Icons.notifications),
                    title: const Text('推播通知'),
                    onTap: () async {
                      switch (
                          ref.read(notificationProvider).authorizationStatus) {
                        case NotificationAuthorizationStatus.authorized:
                          await Clipboard.setData(ClipboardData(
                              text: ref.read(notificationProvider).fcmToken));
                          toastification.show(
                            type: ToastificationType.info,
                            style: ToastificationStyle.flatColored,
                            title: const Text("已複製通知ID到剪貼簿"),
                            description: const Text('請勿隨意分享給他人'),
                            alignment: Alignment.topCenter,
                            showProgressBar: false,
                            autoCloseDuration:
                                const Duration(milliseconds: 1500),
                          );
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
                    trailing: Builder(builder: (context) {
                      String status = '';
                      switch (
                          ref.watch(notificationProvider).authorizationStatus) {
                        case NotificationAuthorizationStatus.authorized:
                          status = '已啟用';
                          break;
                        case NotificationAuthorizationStatus.appDenied:
                        case NotificationAuthorizationStatus.notDetermined:
                          status = '接收通知';
                          break;
                        case NotificationAuthorizationStatus.systemDenied:
                          status = '開啟通知權限';
                          break;
                      }
                      return Text(
                        status,
                        style: const TextStyle(fontSize: 16),
                      );
                    }),
                  ),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                      minLeadingWidth: 30,
                      leading: const Icon(Icons.build),
                      title: const Text('版本'),
                      trailing: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data?.version}',
                              style: const TextStyle(fontSize: 16),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      )),
                  const Divider(
                    height: 0,
                    indent: 50,
                    thickness: 0.5,
                  ),
                  ListTile(
                      minLeadingWidth: 30,
                      leading: const Icon(Icons.build),
                      title: const Text('Build'),
                      trailing: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data?.buildNumber}',
                              style: const TextStyle(fontSize: 16),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      )),
                ],
              )),
        ],
      ),
    );
  }
}
