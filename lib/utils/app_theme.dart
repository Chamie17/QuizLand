import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData appTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.blue.shade50,
      appBarTheme: AppBarTheme(backgroundColor: Colors.blue.shade50),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade300, textStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),),
      ),
      textTheme: const  TextTheme(
          labelSmall: TextStyle(
        fontSize: 24,
        color: Colors.white,
      )),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.brown,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.white,
      selectedLabelStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold
      ),
      unselectedLabelStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
      )
    )
  );

}
