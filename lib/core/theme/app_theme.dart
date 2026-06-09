import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: kBg,
      primaryColor: kAccent,
      cardColor: kSurface,
      dividerColor: kDivider,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: kAccent,
        secondary: kAccent,
        surface: kSurface,
        background: kBg,
        error: kError,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: kTextPrimary,
        onBackground: kTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: kSurface,
        elevation: 0,
        titleTextStyle: kHeadline,
        iconTheme: const IconThemeData(color: kTextPrimary),
        actionsIconTheme: const IconThemeData(color: kTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kSurface,
        selectedItemColor: kAccent,
        unselectedItemColor: kTextSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: TextTheme(
        displayLarge: kDisplayLarge,
        headlineMedium: kHeadline,
        titleMedium: kTitle,
        bodyMedium: kBody,
        bodySmall: kCaption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: Colors.black,
          textStyle: kTitle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusButton),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kAccent,
          side: const BorderSide(color: kAccent, width: 1.5),
          textStyle: kTitle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusButton),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface2,
        hintStyle: kCaption,
        labelStyle: kBody.copyWith(color: kTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusButton),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusButton),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusButton),
          borderSide: const BorderSide(color: kAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusButton),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusButton),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
