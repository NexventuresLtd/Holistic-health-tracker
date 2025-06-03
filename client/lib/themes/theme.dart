// Light Theme Colors
import 'package:flutter/material.dart';

const primaryGreen = Color.fromARGB(255, 124, 8, 8);
const primaryBlue = Color(0xFF2260FF);
const primaryBg = Color(0xFFF1F5FF);
const secondaryGreen = Color.fromARGB(255, 109, 4, 4);
const tertiaryGreen = primaryGreen;
const lightCardColor = Colors.white;
const lightTextColor = Color(0xFF091F44);
const lightSecondaryTextColor = Color(0xFF342B33);

// Dark Theme Colors
const darkPrimaryGreen = primaryGreen; // Keep brand colors consistent
const darkPrimaryBlue = Color(0xFF5B8CFF); // Lighter blue for dark theme
const darkPrimaryBg = Color(0xFF121212);
const darkSecondaryGreen = secondaryGreen;
const darkCardColor = Color(0xFF1E1E1E);
const darkTextColor = Colors.white;
const darkSecondaryTextColor = Color(0xFFB0B0B0);

class AppThemes {
  static ThemeData get lightTheme => ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: primaryGreen,
          secondary: primaryBlue,
          surface: lightCardColor,
          tertiary: tertiaryGreen,
        ),
        cardColor: lightCardColor,
        scaffoldBackgroundColor: primaryBg,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: lightTextColor),
          bodyMedium: TextStyle(color: lightTextColor),
          titleMedium: TextStyle(color: lightTextColor),
          titleSmall: TextStyle(color: lightSecondaryTextColor),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: lightTextColor,
          elevation: 0,
        ),
        // Add other theme overrides as needed
      );

  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: darkPrimaryGreen,
          secondary: darkPrimaryBlue,
          surface: darkCardColor,
          tertiary: Colors.grey,
        ),
        cardColor: darkCardColor,
        scaffoldBackgroundColor: darkPrimaryBg,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: darkTextColor),
          bodyMedium: TextStyle(color: darkTextColor),
          titleMedium: TextStyle(color: darkTextColor),
          titleSmall: TextStyle(color: darkSecondaryTextColor),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkCardColor,
          elevation: 0,
        ),
        // Add other theme overrides as needed
      );
}
