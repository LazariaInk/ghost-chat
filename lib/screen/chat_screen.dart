import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/crypto_utils.dart';

class ChatScreen extends StatefulWidget {
  final String channelName;

  const ChatScreen({super.key, required this.channelName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _encryptionKey;

  @override
  void initState() {
    super.initState();
    _loadEncryptionKey();
  }

  Future<void> _loadEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('${widget.channelName}_key');
    if (key == null || key.isEmpty) {
      print(
          '❌ Cheia de criptare nu a fost găsită pentru canalul: ${widget.channelName}');
    } else {
      print('🔑 Cheia de criptare a fost încărcată: $key');
    }
    setState(() {
      _encryptionKey = key;
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && _encryptionKey != null) {
      String plainMessage = _messageController.text;
      String encryptedMessage =
      CryptoUtils.encryptMessage(plainMessage, _encryptionKey!);

      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print('❌ Documentul utilizatorului nu există pentru UID: $userId');
        return;
      }

      final userName = userDoc['name'] ?? 'User Anonim';
      print('✅ Numele utilizatorului: $userName');

      await FirebaseFirestore.instance
          .collection('channels')
          .doc(widget.channelName)
          .collection('messages')
          .add({
        'content': encryptedMessage,
        'senderId': userId,
        'senderName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      print('✅ Mesaj trimis de $userName');
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('channels')
                  .doc(widget.channelName)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final messages = snapshot.data!.docs.map((doc) {
                  final encryptedMessage = doc['content'];
                  String decryptedMessage = '*** Decrypt Error ***';
                  try {
                    if (_encryptionKey != null && _encryptionKey!.isNotEmpty) {
                      decryptedMessage = CryptoUtils.decryptMessage(
                          encryptedMessage, _encryptionKey!);
                    } else {
                      print('❌ Cheia de criptare este null sau goală!');
                    }
                  } catch (e) {
                    print(
                        '❌ Eroare la decriptare pentru mesajul: $encryptedMessage');
                  }
                  return ListTile(
                    title: Text(decryptedMessage),
                    subtitle: Text(doc['senderName']),
                  );
                }).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView(
                  controller: _scrollController,
                  children: messages,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Write a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
