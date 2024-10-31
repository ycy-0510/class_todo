import 'dart:io';

import 'package:class_todo_list/adaptive_action.dart';
import 'package:class_todo_list/page/class_page.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/page/loading_page.dart';
import 'package:class_todo_list/theme.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:class_todo_list/logic/auth_notifier.dart';
import 'package:class_todo_list/page/login_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
final _messageStreamController = BehaviorSubject<RemoteMessage>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    appleProvider: kDebugMode
        ? AppleProvider.debug
        : Platform.isIOS
            ? AppleProvider.appAttestWithDeviceCheckFallback
            : AppleProvider.deviceCheck,
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    webProvider:
        ReCaptchaEnterpriseProvider('6LdOJ10oAAAAAGthrAXTn_Fk3GaHCoex00TVuEDw'),
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _messageStreamController.sink.add(message);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://be3ad80836734814db0aeb3bafab4eb0@o4508194045362176.ingest.de.sentry.io/4508194049163344';
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: MainApp(),
      ),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthState authState = ref.watch(authProvider);
    _messageStreamController.listen((message) {
      if (message.notification != null) {
        toastification.show(
          type: ToastificationType.info,
          style: ToastificationStyle.flatColored,
          title: Text(message.notification?.title ?? '您有一則新通知'),
          description: Text(message.notification?.body ?? ''),
          alignment: Alignment.topCenter,
          showProgressBar: false,
          autoCloseDuration: const Duration(milliseconds: 5000),
        );
      }
    });
    return BetterFeedback(
      localeOverride: const Locale('zh', 'TW'),
      theme: feedBackLightTheme,
      darkTheme: feedBackDarkTheme,
      themeMode: ThemeMode.system,
      child: ToastificationWrapper(
        child: MaterialApp(
          navigatorKey: _rootNavigatorKey,
          theme: lightTheme,
          darkTheme: darkTheme,
          title: '共享聯絡簿',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'TW'),
          ],
          locale: const Locale('zh', 'TW'),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return ForceUpdateWidget(
              navigatorKey: _rootNavigatorKey,
              forceUpdateClient: ForceUpdateClient(
                fetchRequiredVersion: () => Future.value(ref
                    .read(remoteConfigProvider.notifier)
                    .getRequiredVersion()),
                iosAppStoreId: '6670305489',
              ),
              allowCancel: ref
                  .read(remoteConfigProvider.notifier)
                  .getAllowCancelUpdate(),
              showForceUpdateAlert: (context, allowCancel) =>
                  showAdaptiveDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => AlertDialog.adaptive(
                  title: const Text('需要更新軟體'),
                  content: const Text('請更新到最新版以繼續使用'),
                  actions: <Widget>[
                    if (allowCancel)
                      AdaptiveAction(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('稍後更新'),
                      ),
                    AdaptiveAction(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('立即更新'),
                    ),
                  ],
                ),
              ),
              showStoreListing: (storeUrl) async {
                if (await canLaunchUrl(storeUrl)) {
                  await launchUrl(
                    storeUrl,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              onException: (error, st) {
                toastification.show(
                  type: ToastificationType.error,
                  style: ToastificationStyle.flatColored,
                  title: const Text("發生錯誤"),
                  description: Text(error.toString()),
                  alignment: Alignment.topCenter,
                  showProgressBar: false,
                  autoCloseDuration: const Duration(milliseconds: 1500),
                );
              },
              child: child!,
            );
          },
          home: Builder(builder: (context) {
            if (!authState.init) {
              return const LoadingPage();
            } else if (!authState.loggedIn) {
              return const LoginPage();
            } else if (authState.classCode == null) {
              return const ClassesPage();
            } else {
              return const HomePage();
            }
          }),
        ),
      ),
    );
  }
}
