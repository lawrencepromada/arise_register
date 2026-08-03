import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData darkTheme = ThemeData(

    brightness: Brightness.dark,

    scaffoldBackgroundColor: Colors.black,

    primaryColor: Colors.amber,

    inputDecorationTheme: const InputDecorationTheme(

      border: OutlineInputBorder(),

    ),

    elevatedButtonTheme: ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        backgroundColor: Colors.amber,

        foregroundColor: Colors.black,

        minimumSize: const Size(double.infinity, 50),

      ),

    ),

  );

}