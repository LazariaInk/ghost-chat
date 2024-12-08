import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Channel> filteredChannels = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChannels();
    filteredChannels = channels;
    _searchController.addListener(_filterChannels);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _saveChannels() async {
    final prefs = await SharedPreferences.getInstance();
    final channelList = channels.map((channel) => channel.toJson()).toList();
    prefs.setString('channels', jsonEncode(channelList));
  }

  Future<void> _loadChannels() async {
    final prefs = await SharedPreferences.getInstance();
    final String? channelData = prefs.getString('channels');
    if (channelData != null) {
      final List<dynamic> jsonList = jsonDecode(channelData);
      setState(() {
        channels = jsonList.map((json) => Channel.fromJson(json)).toList();
        filteredChannels = channels;
      });
    }
  }

  void _addChannel(Channel channel) {
    setState(() {
      channels.add(channel);
      filteredChannels = channels;
    });
    _saveChannels();
  }

  void _deleteChannel(Channel channel) {
    setState(() {
      channels.remove(channel);
      filteredChannels = channels;
    });
    _saveChannels();
  }

  Future<void> _showDeleteConfirmationDialog(Channel channel) async {
    final TextEditingController confirmationController =
    TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmare ștergere'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Pentru a șterge canalul, scrieți „DELETE” în câmpul de mai jos:'),
              const SizedBox(height: 10),
              TextField(
                controller: confirmationController,
                decoration: const InputDecoration(
                  labelText: 'Scrieți DELETE',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                if (confirmationController.text.toUpperCase() == 'DELETE') {
                  Navigator.of(context).pop(true); // Confirm delete
                }
              },
              child: const Text('Șterge'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _deleteChannel(channel);
    }
  }

  void _filterChannels() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredChannels = channels
          .where((channel) => channel.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canale'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Caută un canal...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredChannels.length,
              itemBuilder: (context, index) {
                final channel = filteredChannels[index];
                return ListTile(
                  title: Text(channel.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(channel);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(channelName: channel.name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddChannelScreen(),
            ),
          );
          if (result != null && result is Channel) {
            _addChannel(result);
          }
        },
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
