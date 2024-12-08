import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import MyApp for MyAppState

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
    });
  }

  void _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });

    final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.toggleThemeMode(value);
  }

  void _changeLanguage(String newLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', newLanguage);
    setState(() {
      _selectedLanguage = newLanguage;
    });

    final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.setLocale(Locale(newLanguage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.notifications),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.darkTheme),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.termsAndConditions),
            onTap: () {},
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.selectLanguage),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ro', child: Text('Română')),
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
              ],
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  _changeLanguage(newLanguage);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
