import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:henshin/splash/splash_widget.dart';
import 'package:firebase_core/firebase_core.dart';

// void main() async {
//   runApp(MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool displaySplashImage = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(seconds: 1), () => setState(() => displaySplashImage = false));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Henshin-App',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(primarySwatch: Colors.blue),
      home: displaySplashImage
          ? Container(
              color: Colors.white,
              child: Builder(
                builder: (context) => Image.asset(
                  'assets/images/shot-cropped-1576957517751.png',
                  fit: BoxFit.scaleDown,
                ),
              ),
            )
          : const SplashWidget(),
    );
  }
}
