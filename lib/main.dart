// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ghostchat/screen/main_screen.dart';
import 'package:ghostchat/screen/sign_in_screen.dart';
import 'package:ghostchat/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBorOa_Uv13CKsEUx3wY2VbaX57mq-IXBo',
      appId: '1:970751112043:android:df8b0f6fd1d7887ed0522e',
      messagingSenderId: '970751112043',
      projectId: 'ghost-chat-ca6f7',
      storageBucket: 'ghost-chat-ca6f7.firebaseapp.com',
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final String? savedLanguageCode = prefs.getString('selectedLanguage') ?? 'ro';
  runApp(MyApp(initialLocale: Locale(savedLanguageCode!)));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  static void setLocale(BuildContext context, Locale newLocale) {
    final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale; // 🔥 Limbă inițială
    _loadThemeMode();
  }

  void setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', locale.languageCode); // 🔥 Salvează limba selectată
    setState(() {
      _locale = locale; // 🔥 Actualizează limba aplicației
    });
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghost chat',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ro', ''),
        Locale('ru', ''),
      ],
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
