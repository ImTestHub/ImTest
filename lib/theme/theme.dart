import 'package:flutter/material.dart';
import 'package:go_transitions/go_transitions.dart';

class AppTheme {
  static TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle titleSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle bodyLarge = TextStyle(fontSize: 16);

  static TextStyle bodyMedium = TextStyle(fontSize: 14);

  static TextStyle bodySmall = TextStyle(fontSize: 12);

  static ThemeData theme([bool? isDark]) {
    final colorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: isDark == true ? Brightness.dark : Brightness.light,
    );

    final cardColor = isDark == true ? Colors.black : Colors.white;

    final backgroundColor = isDark == true
        ? Color(0xff212121)
        : Color(0xfff1f2f3);

    final TextTheme textTheme = TextTheme(
      titleLarge: titleLarge.copyWith(color: colorScheme.onSurface),
      titleMedium: titleMedium.copyWith(color: colorScheme.onSurface),
      titleSmall: titleSmall.copyWith(color: colorScheme.onSurface),
      bodyLarge: bodyLarge.copyWith(
        color: colorScheme.onSurface.withAlpha(200),
      ),
      bodyMedium: bodyMedium.copyWith(
        color: colorScheme.onSurface.withAlpha(200),
      ),
      bodySmall: bodySmall.copyWith(
        color: colorScheme.onSurface.withAlpha(200),
      ),
    );

    return ThemeData(
      fontFamily: "Arial",
      colorScheme: colorScheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: cardColor,
        titleTextStyle: textTheme.titleMedium,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: GoTransitions.cupertino,
          TargetPlatform.macOS: GoTransitions.cupertino,
          TargetPlatform.android: GoTransitions.cupertino,
        },
      ),
      cardTheme: CardThemeData(color: cardColor),
      scaffoldBackgroundColor: backgroundColor,
      iconTheme: IconThemeData(size: 18, color: colorScheme.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        constraints: BoxConstraints(maxHeight: 66),
        fillColor: cardColor,
        filled: true,
        hintStyle: TextStyle(fontSize: 14),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(66)),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData darkTheme() {
    return theme(true);
  }
}
