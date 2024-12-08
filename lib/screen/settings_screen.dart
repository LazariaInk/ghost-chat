import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setări'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Notificări"),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          ListTile(
            title: const Text("Tema întunecată"),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          ListTile(
            title: const Text("Termeni și condiții"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
