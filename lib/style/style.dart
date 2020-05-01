import 'package:flutter/material.dart';

abstract class Styles {
  static const primaryColor = Color(0xFFCE93D8);

  static const boxBorderWith = 2.0;

  static const circlePadding = EdgeInsets.only(bottom: 15, left: 15);

  static const diffColor = Colors.amber;

  static const diffTextColor = Colors.black;

  static const settingsTextColor = Colors.white;

  static const buttonColor = Colors.teal;

  static const backgroundColor = Color(0xFF212121);

  static const infoTextStyle = TextStyle(
    decoration: TextDecoration.none,
    fontSize: 16,
    color: Colors.white,
    //fontWeight: FontWeight.w300
  );

  static const infoTitleStyle = TextStyle(
    decoration: TextDecoration.none,
    fontSize: 20,
    color: Colors.white,
    //fontWeight: FontWeight.w300
  );

  static const settingsDate = TextStyle(
    decoration: TextDecoration.none,
    fontSize: 20,
    color: Colors.white,
    //fontWeight: FontWeight.w300
  );

  static const settingsTitle = TextStyle(
    decoration: TextDecoration.none,
    fontSize: 16,
    color: Styles.settingsTextColor,
    //fontWeight: FontWeight.w300
  );

  static const settingsValues = TextStyle(
    decoration: TextDecoration.none,
    fontSize: 16,
    color: Styles.settingsTextColor,
    fontWeight: FontWeight.w300

  );

    static const MaterialColor primaryThemeColor = const MaterialColor(
    0xFFCE93D8,
    const <int, Color>{
      50: const Color(0xFFCE93D8),
      100: const Color(0xFFCE93D8),
      200: const Color(0xFFCE93D8),
      300: const Color(0xFFCE93D8),
      400: const Color(0xFFCE93D8),
      500: const Color(0xFFCE93D8),
      600: const Color(0xFFCE93D8),
      700: const Color(0xFFCE93D8),
      800: const Color(0xFFCE93D8),
      900: const Color(0xFFCE93D8),
    },
  );

  static const editTextColor = Colors.white;

  static const editFieldBackgroundColor = Colors.white24;

  static const editFieldPadding = EdgeInsets.only(left:0);

  static var dialogButtonStyle = TextStyle(
    decoration: TextDecoration.none,
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.white,
  );

  static var colorButtonTextStyle = TextStyle(
    decoration: TextDecoration.none,
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Styles.primaryColor,
  );

  static const formFieldPadding = EdgeInsets.only(left:6);
  static const formErrorColor = Colors.redAccent;

  static const dialogTextStyle = TextStyle(
    decoration: TextDecoration.none,
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.white,
  );

}
