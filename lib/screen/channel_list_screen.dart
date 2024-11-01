import 'package:flutter/material.dart';
import 'add_channel_screen.dart';
import 'chat_screen.dart';
import '../model/channel.dart';

class ChannelListScreen extends StatefulWidget {
  const ChannelListScreen({super.key});

  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  List<Channel> channels = [];

  void _addChannel(Channel channel) {
    setState(() {
      channels.add(channel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          return ListTile(
            title: Text(channel.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(channelName: channel.name),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddChannelScreen(),
            ),
          );
          if (result != null && result is Channel) {
            _addChannel(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
