import 'package:flutter/material.dart';
import 'package:henshin/splash/splash_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Henshin App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashWidget(),
    );
  }
}
