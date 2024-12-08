import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String channelName;

  const ChatScreen({super.key, required this.channelName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: $channelName'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                ListTile(title: Text("User1: Salutare!")),
                ListTile(title: Text("User2: Bună!")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Scrie un mesaj...',
                      border: OutlineInputBorder(),
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
