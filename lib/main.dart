import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ghostchat/screen/sign_in_screen.dart';
import 'package:ghostchat/screen/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBorOa_Uv13CKsEUx3wY2VbaX57mq-IXBo',
      appId: '1:970751112043:android:df8b0f6fd1d7887ed0522e',
      messagingSenderId: '970751112043',
      projectId: 'ghost-chat-ca6f7',
      storageBucket: 'ghost-chat-ca6f7.firebasestorage.app',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghost chat',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const MainScreen();
          } else {
            return const SignInScreen();
          }
        },
      ),
    );
  }
}
