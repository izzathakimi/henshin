import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_with_email_page/login_with_email_page_widget.dart';
import 'splash/splash_widget.dart';  // Add this import
import 'package:provider/provider.dart';
import 'application_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Henshin App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SplashWidget(), // Changed from LoginWithEmailPageWidget
    );
  }
}
