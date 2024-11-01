import 'package:flutter/material.dart';
import '../model/channel.dart';

class AddChannelScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();

  AddChannelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaugă Canal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Numele canalului'),
            ),
            TextField(
              controller: _secretKeyController,
              decoration: const InputDecoration(labelText: 'Cheie secretă'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _secretKeyController.text.isNotEmpty) {
                  final newChannel = Channel(
                    name: _nameController.text,
                    secretKey: _secretKeyController.text,
                  );
                  Navigator.pop(context, newChannel);
                }
              },
              child: const Text('Adaugă Canal'),
            ),
          ],
        ),
      ),
    );
  }
}
