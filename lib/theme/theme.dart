import 'package:flutter/material.dart';

class FlutterTodosTheme {
  static const _blocBlue = Color(0xFF13B9FF);

  static ThemeData get light {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        color: _blocBlue,
      ),
      colorScheme: ColorScheme.fromSwatch(
        accentColor: _blocBlue,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      toggleableActiveColor: _blocBlue,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        color: _blocBlue,
      ),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
        accentColor: _blocBlue,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      toggleableActiveColor: _blocBlue,
    );
  }
}
