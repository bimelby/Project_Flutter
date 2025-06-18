import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  final SharedPreferences prefs;

  ThemeProvider(this.prefs) {
    loadTheme();
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme() {
    themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }

  void loadTheme() {
    final isDark = prefs.getBool('isDarkMode') ?? false;
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyThemes {
  static final Color primaryColor = Color(0xFF3B82F6);
  static final Color accentColor = Color(0xFF60A5FA);

  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'NotoSans',
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSans',
      ),
    ),
    
    textTheme: TextTheme(
    displayLarge: TextStyle(color: Colors.black87, fontFamily: 'NotoSans'),
    displayMedium: TextStyle(color: Colors.black87, fontFamily: 'NotoSans'),
    bodyLarge: TextStyle(color: Colors.black87, fontFamily: 'NotoSans'),
    bodyMedium: TextStyle(color: Colors.black87, fontFamily: 'NotoSans'),
  ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    fontFamily: 'NotoSans',
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      background: Color(0xFF121212),
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSans',
      ),
    ),
    textTheme: TextTheme(
    displayLarge: TextStyle(color: Colors.white, fontFamily: 'NotoSans'),
    displayMedium: TextStyle(color: Colors.white, fontFamily: 'NotoSans'),
    bodyLarge: TextStyle(color: Colors.white, fontFamily: 'NotoSans'),
    bodyMedium: TextStyle(color: Colors.white, fontFamily: 'NotoSans'),
  ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );
}
