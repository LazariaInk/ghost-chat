import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../model/channel.dart';

class AddChannelScreen extends StatefulWidget {
  const AddChannelScreen({super.key});

  @override
  _AddChannelScreenState createState() => _AddChannelScreenState();
}

class _AddChannelScreenState extends State<AddChannelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();

  String _selectedAlgorithm = 'AES';
  final List<String> _encryptionAlgorithms = ['AES', 'RSA', 'ChaCha20'];

  bool _isKeyVisible = false;

  String _generateRandomKey(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addChannel),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.channelName,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _secretKeyController,
                    obscureText: !_isKeyVisible,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.secretKey,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isKeyVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isKeyVisible = !_isKeyVisible;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    final randomKey = _generateRandomKey(16);
                    setState(() {
                      _secretKeyController.text = randomKey;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedAlgorithm,
              items: _encryptionAlgorithms.map((String algorithm) {
                return DropdownMenuItem<String>(
                  value: algorithm,
                  child: Text(algorithm),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedAlgorithm = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.encryptionAlgorithm,
              ),
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
              child: Text(AppLocalizations.of(context)!.addChannel),
            ),
          ],
        ),
      ),
    );
  }
}
