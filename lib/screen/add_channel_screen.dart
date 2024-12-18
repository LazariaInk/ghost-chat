import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/channel.dart';
import '../utils/dialog_utils.dart';

class AddChannelScreen extends StatefulWidget {
  const AddChannelScreen({super.key});

  @override
  _AddChannelScreenState createState() => _AddChannelScreenState();
}

class _AddChannelScreenState extends State<AddChannelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addChannel),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.createChannelTab),
            Tab(text: AppLocalizations.of(context)!.connectingToAChannelTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CreateChannelTab(),
          JoinChannelTab(),
        ],
      ),
    );
  }
}

class CreateChannelTab extends StatefulWidget {
  const CreateChannelTab({super.key});

  @override
  _CreateChannelTabState createState() => _CreateChannelTabState();
}

class _CreateChannelTabState extends State<CreateChannelTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();

  final String _selectedAlgorithm = 'AES';

  bool _isKeyVisible = false;

  String _generateRandomKey(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<void> _saveChannelToFirestore(
      String channelName, String algorithm) async {
    try {
      await FirebaseFirestore.instance
          .collection('channels')
          .doc(channelName)
          .set({
        'name': channelName,
        'encryptionAlgorithm': algorithm,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      DialogUtils.showErrorDialog(
        context,
        AppLocalizations.of(context)!.addChannelErrorMessage,
        AppLocalizations.of(context)!.checkConnectionMessage,
      );
    }
  }

  Future<void> _saveEncryptionKey(String channelName, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${channelName}_key', key);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                icon: Icon(
                    _isKeyVisible ? Icons.visibility : Icons.visibility_off),
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
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty &&
                  _secretKeyController.text.isNotEmpty) {
                final channelName = _nameController.text.trim();
                final secretKey = _secretKeyController.text.trim();

                await _saveChannelToFirestore(channelName, _selectedAlgorithm);
                await _saveEncryptionKey(channelName, secretKey);

                final newChannel = Channel(
                  name: channelName,
                  secretKey: secretKey,
                );
                Navigator.pop(context, newChannel);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .addChannelAllFieldsReqMessage)),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.createChannelTab),
          ),
        ],
      ),
    );
  }
}

class JoinChannelTab extends StatefulWidget {
  const JoinChannelTab({super.key});

  @override
  _JoinChannelTabState createState() => _JoinChannelTabState();
}

class _JoinChannelTabState extends State<JoinChannelTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();

  bool _isLoading = false;

  Future<void> _joinChannel() async {
    setState(() {
      _isLoading = true;
    });

    final channelName = _nameController.text.trim();
    final secretKey = _secretKeyController.text.trim();

    if (channelName.isEmpty || secretKey.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .connectingChannelAllFieldsReqMessage)),
      );
      return;
    }

    try {
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('${channelName}_key', secretKey);
      });

      Navigator.pop(context, Channel(name: channelName, secretKey: secretKey));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.errorOnChannelConnection)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.channelName,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _secretKeyController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.secretKey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _joinChannel,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(AppLocalizations.of(context)!.connectingButton),
          ),
        ],
      ),
    );
  }
}
