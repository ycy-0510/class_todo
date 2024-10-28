import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

final lightTheme = ThemeData(
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.all(10),
    foregroundColor: Colors.blue,
    side: const BorderSide(
      color: Colors.blue,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  )),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
  splashFactory: NoSplash.splashFactory,
);

final darkTheme = ThemeData(
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(10),
      foregroundColor: Colors.blue,
      side: const BorderSide(
        color: Colors.blue,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    )),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
    splashFactory: NoSplash.splashFactory);

final feedBackLightTheme = FeedbackThemeData(
  colorScheme: lightTheme.colorScheme,
  feedbackSheetColor:
      lightTheme.bottomSheetTheme.backgroundColor ?? Colors.white,
  bottomSheetDescriptionStyle:
      lightTheme.textTheme.titleMedium ?? const TextStyle(color: Colors.black),
  bottomSheetTextInputStyle:
      lightTheme.textTheme.titleMedium ?? const TextStyle(color: Colors.black),
  drawColors: [
    Colors.black,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.red
  ],
  brightness: Brightness.light,
);

final feedBackDarkTheme = FeedbackThemeData(
  colorScheme: darkTheme.colorScheme,
  feedbackSheetColor:
      darkTheme.bottomSheetTheme.backgroundColor ?? Colors.black,
  bottomSheetDescriptionStyle:
      darkTheme.textTheme.titleMedium ?? const TextStyle(color: Colors.white),
  bottomSheetTextInputStyle:
      darkTheme.textTheme.titleMedium ?? const TextStyle(color: Colors.white),
  drawColors: [
    Colors.white,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.red
  ],
  brightness: Brightness.dark,
);
