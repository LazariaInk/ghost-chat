import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart'; // Import MyApp pentru a folosi setLocale

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';

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
            trailing: Switch(value: false, onChanged: (val) {}),
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
                  setState(() {
                    _selectedLanguage = newLanguage;
                    Locale newLocale = Locale(newLanguage);
                    MyApp.setLocale(context, newLocale);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
