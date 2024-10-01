import 'dart:io';

import 'package:class_todo_list/page/class_page.dart';
import 'package:class_todo_list/page/loading_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:class_todo_list/logic/auth_notifier.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/page/login_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toastification/toastification.dart';
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
  runApp(const ProviderScope(
    child: MainApp(),
  ));
}

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
    return ToastificationWrapper(
      child: MaterialApp.router(
        theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            cardTheme: const CardTheme(
              color: Colors.white,
              shadowColor: Colors.transparent,
              elevation: 0,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            scaffoldBackgroundColor: const Color.fromARGB(255, 243, 242, 247),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 243, 242, 247),
              surfaceTintColor: Color.fromARGB(255, 243, 242, 247),
              centerTitle: true,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey.shade700),
            segmentedButtonTheme: SegmentedButtonThemeData(
                style: SegmentedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              selectedBackgroundColor: Colors.blue.shade100,
              backgroundColor: Colors.white,
              selectedForegroundColor: Colors.blue.shade900,
              foregroundColor: Colors.blue.shade900,
            )),
            buttonTheme: const ButtonThemeData(
              buttonColor: Colors.blue,
              textTheme: ButtonTextTheme.primary,
              padding: EdgeInsets.all(10),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(10),
              foregroundColor: Colors.blue,
              side: const BorderSide(
                color: Colors.blue,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            )),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), gapPadding: 5),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                gapPadding: 5,
                borderSide: const BorderSide(color: Colors.blue),
              ),
              floatingLabelStyle: const TextStyle(color: Colors.blue),
            ),
            splashFactory: NoSplash.splashFactory),
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            cardTheme: const CardTheme(
              color: Color.fromARGB(255, 28, 28, 30),
              shadowColor: Colors.transparent,
              elevation: 0,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Color.fromARGB(255, 28, 28, 30),
            ),
            dialogBackgroundColor: const Color.fromARGB(255, 28, 28, 30),
            appBarTheme: const AppBarTheme(
              color: Colors.black,
              surfaceTintColor: Colors.black,
              centerTitle: true,
            ),
            scaffoldBackgroundColor: Colors.black,
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: const Color.fromARGB(255, 28, 28, 30),
                selectedItemColor: Colors.blue.shade300,
                unselectedItemColor: Colors.white),
            segmentedButtonTheme: SegmentedButtonThemeData(
                style: SegmentedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              selectedBackgroundColor: Colors.lightBlue.shade700,
              backgroundColor: const Color.fromARGB(255, 28, 28, 30),
              selectedForegroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue.shade200,
            )),
            buttonTheme: const ButtonThemeData(
              buttonColor: Colors.blue,
              textTheme: ButtonTextTheme.primary,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(10),
              foregroundColor: Colors.blue,
              side: const BorderSide(
                color: Colors.blue,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            )),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), gapPadding: 5),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                gapPadding: 5,
                borderSide: const BorderSide(color: Colors.blue),
              ),
              floatingLabelStyle: const TextStyle(color: Colors.blue),
            ),
            splashFactory: NoSplash.splashFactory),
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
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                if (!authState.init) {
                  return const LoadingPage();
                } else if (!authState.loggedIn) {
                  return const LoginPage();
                } else if (authState.classCode == null) {
                  return const ClassesPage();
                } else {
                  return const HomePage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
