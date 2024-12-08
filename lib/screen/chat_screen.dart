import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import pentru AppLocalizations

class ChatScreen extends StatelessWidget {
  final String channelName;

  const ChatScreen({super.key, required this.channelName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.channelName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text("User1: haha"),
                ),
                ListTile(
                  title: Text("User2: hello"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.writeAMessage, // Folosim cheia pentru "writeAMessage"
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Aici se va adăuga logica de trimitere a mesajului
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
