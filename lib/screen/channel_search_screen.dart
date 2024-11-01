import 'package:flutter/material.dart';

class ChannelSearchScreen extends StatelessWidget {
  const ChannelSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caută Canale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Caută un canal...',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                // Aici poți implementa logica de căutare
              },
            ),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(title: Text("Canal exemplu")),
                  ListTile(title: Text("Alt canal")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
