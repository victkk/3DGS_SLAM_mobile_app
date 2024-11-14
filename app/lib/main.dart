/*
 * @Author: vic123 zhangzc_efz@163.com
 * @Date: 2024-09-03 16:48:14
 * @LastEditors: vic123 zhangzc_efz@163.com
 * @LastEditTime: 2024-09-12 18:11:11
 * @FilePath: \app\lib\main.dart
 * @Description: 
 * 
 * Copyright (c) 2024 by vic123, All Rights Reserved. 
 */
import 'package:app/VideoStream/VideoStreaming.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,  // Disable the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light, // 选择亮色或暗色主题
        primaryColor: const Color(0xFF0D47A1), // 主色调
        scaffoldBackgroundColor: const Color(0xFFF1F8E9), // Scaffold 背景色
        appBarTheme: const AppBarTheme(
          color: Color(0xFF1E88E5), // AppBar 颜色
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: const Color(0xFF0D47A1), // 按钮背景色
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFA000), // FAB背景色
          foregroundColor: Colors.white, // FAB图标颜色
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.grey,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0D47A1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E88E5)),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF0D47A1),
          ),
        ),
      ),
      home: const VideoStream(),
    );
  }
}
