import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jurnal_prakerin/splash_screen.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAX2nEmDaET0uAfHHKUx9BKcM6ITpnTJQA",
          appId: "1:818058500283:android:5e521bcde6e46cc44df19e",
          messagingSenderId: "818058500283",
          projectId: "jurnal-prakerin"));

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Jurnal Prakerin',
              textAlign: TextAlign.center,
            ),
            content: Text(
              'Ada Notifikasi Baru',
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    }
  });
  runApp(const MainApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
