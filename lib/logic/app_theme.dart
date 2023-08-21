import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeData get themeData => _isDarkTheme ? darkTheme : lightTheme;

  ThemeData getCurrentTheme() {
    return _isDarkTheme ? darkTheme : lightTheme;
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _saveThemeToPreferences();
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.black.withOpacity(0.7), 
      shadowColor: Colors.black,
      hintColor: const Color.fromARGB(251, 110, 110, 110),
      secondaryHeaderColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xffFFB0C9),
        foregroundColor: Colors.black,
        shadowColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xffFFB0C9),
        selectedItemColor: Colors.black.withOpacity(0.80),
        selectedIconTheme: IconThemeData(color: Colors.black.withOpacity(0.8)),
        unselectedIconTheme:
            IconThemeData(color: Colors.black.withOpacity(0.6)),
        unselectedItemColor: Colors.black.withOpacity(0.60),
        selectedLabelStyle: const TextStyle(
          color: Colors.black,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.black54,
        contentPadding: EdgeInsets.only(left: 15),
        textColor: Colors.black,
        tileColor: Color.fromARGB(255, 255, 190, 211),
      ),
      sliderTheme: const SliderThemeData(
        thumbColor: Color.fromARGB(255, 255, 179, 206),
        activeTrackColor: Color.fromARGB(
            255, 245, 128, 167), 
        trackHeight: 18,
        trackShape: RoundedRectSliderTrackShape(),
        inactiveTrackColor: Color.fromARGB(255, 248, 144, 179),
        activeTickMarkColor: Color.fromARGB(255, 255, 179, 206),
        inactiveTickMarkColor: Color.fromARGB(255, 255, 179, 206),
      ),
      scaffoldBackgroundColor:
          const Color.fromARGB(255, 238, 238, 238).withOpacity(0.9),
      iconTheme: IconThemeData(color: Colors.black.withOpacity(0.7)),
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          color: Colors.black,
          fontSize: 21,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0), 
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0xffFFB0C9)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xffFFB0C9),
      ),
      colorScheme: const ColorScheme(
        background: Color.fromARGB(239, 255, 188, 211),
        surface: Color.fromARGB(
            255, 255, 182, 193), 
        brightness: Brightness.light, 
        error: Color(0xffB00020),
        onBackground: Color.fromARGB(
            255, 0, 0, 0),
        primary: Color.fromARGB(255, 184, 92, 135),
        secondary:
            Color.fromARGB(255, 255, 0, 0), 
        onError: Color.fromARGB(
            255, 255, 255, 255), 
        onPrimary:
            Color.fromARGB(216, 0, 0, 0), 
        onSecondary: Color.fromARGB(
            255, 255, 255, 255), 
        onSurface:
            Color.fromARGB(255, 0, 0, 0), 
      ).copyWith(
        error: const Color(0xffB00020),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.white, 
      shadowColor: Colors.white,
      hintColor: const Color.fromARGB(255, 112, 112, 112),
      secondaryHeaderColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white.withOpacity(0.80),
        selectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.8)),
        unselectedIconTheme:
            IconThemeData(color: Colors.white.withOpacity(0.6)),
        unselectedItemColor: Colors.white.withOpacity(0.60),
        selectedLabelStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 21,
        ),
      ),
      iconTheme: IconThemeData(color: Colors.white.withOpacity(0.8)),
      listTileTheme: const ListTileThemeData(
        iconColor: Color.fromARGB(137, 214, 214, 214),
        contentPadding: EdgeInsets.only(left: 15),
        textColor: Colors.white,
        tileColor: Colors.deepPurple,
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      sliderTheme: const SliderThemeData(
        thumbColor: Colors.deepPurple,
        activeTrackColor: Color.fromARGB(255, 142, 115, 214),
        trackHeight: 18,
        trackShape: RoundedRectSliderTrackShape(),
        inactiveTrackColor: Color.fromARGB(255, 55, 28, 104),
        activeTickMarkColor: Color.fromARGB(255, 157, 135, 218),
        inactiveTickMarkColor: Color.fromARGB(255, 142, 116, 212),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(
              color: Color.fromARGB(
                  255, 255, 255, 255), 
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color.fromARGB(255, 120, 79, 192),
      ),
      colorScheme: const ColorScheme(
        background: Colors.deepPurple,
        surface: Color.fromARGB(
            255, 160, 150, 190), 
        brightness:
            Brightness.light, 
        error: Color(0xffB00020),
        onBackground: Color.fromARGB(
            255, 0, 0, 0), 
        primary: Color.fromARGB(255, 67, 14, 97), 
        secondary:
            Color.fromARGB(255, 255, 0, 0), 
        onError: Color.fromARGB(
            255, 255, 255, 255), 
        onPrimary: Color.fromARGB(235, 226, 226, 226), 
        onSecondary: Color.fromARGB(
            255, 255, 255, 255), 
        onSurface:
            Color.fromARGB(255, 0, 0, 0), 
      ).copyWith(
        error: const Color(0xffB00020),
      ),
    );
  }

  void changeAndSaveTheme(BuildContext context,
      AppThemeProvider appThemeProvider, String themeMode) {
    appThemeProvider.toggleTheme();
    final prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      prefs.setString('themeMode', themeMode);
    });
  }

  Future<void> initializeTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    _isDarkTheme = isDarkTheme;
    notifyListeners();
  }

  Future<void> _saveThemeToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _isDarkTheme);
  }
}