import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import "package:image/image.dart" as img;
import 'dart:convert';
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
    setState(() {
      _encryptionKey = key;
    });
  }

  Future<String> _compressImage(String imagePath) async {
    final originalImage = File(imagePath);
    final imageBytes = await originalImage.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);
    final resizedImage = img.copyResize(decodedImage!, width: 420);
    final compressedImageBytes = img.encodeJpg(resizedImage, quality: 40);
    final tempDir = Directory.systemTemp;
    final compressedImagePath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressedImageFile = File(compressedImagePath);
    await compressedImageFile.writeAsBytes(compressedImageBytes);
    return compressedImagePath;
  }

  Future<String> _convertImageToBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }

  void _sendMessage({String? imagePath}) async {
    if ((_messageController.text.isNotEmpty || imagePath != null) &&
        _encryptionKey != null) {
      setState(() {});

      try {
        String plainMessage = _messageController.text;
        if (imagePath != null) {
          final compressedImagePath = await _compressImage(imagePath);
          final base64Image = await _convertImageToBase64(compressedImagePath);
          plainMessage = 'image:$base64Image';
        }
        String encryptedMessage =
            CryptoUtils.encryptMessage(plainMessage, _encryptionKey!);

        final userId = FirebaseAuth.instance.currentUser?.uid;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final userName = userDoc['name'] ?? 'Anonymous User';

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
        _scrollToBottom();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.errorSendMessage)),
        );
      } finally {
        setState(() {});
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
                  String decryptedMessage = encryptedMessage;
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  final isMyMessage = doc['senderId'] == userId;
                  try {
                    decryptedMessage = CryptoUtils.decryptMessage(
                        encryptedMessage, _encryptionKey!);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .errorDecryptingMessage)),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: isMyMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMyMessage
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['senderName'] ?? 'Unknown User',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: decryptedMessage.startsWith('image:')
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FullScreenImage(
                                            imageData: base64Decode(
                                                decryptedMessage.substring(6))),
                                      ),
                                    )
                                : () => Clipboard.setData(
                                    ClipboardData(text: decryptedMessage)),
                            child: Container(
                              padding: const EdgeInsets.all(1.0),
                              decoration: BoxDecoration(
                                color: isMyMessage
                                    ? Theme.of(context)
                                        .appBarTheme
                                        .backgroundColor
                                    : Theme.of(context)
                                        .appBarTheme
                                        .backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: decryptedMessage.startsWith('image:')
                                  ? Image.memory(
                                      base64Decode(
                                          decryptedMessage.substring(6)),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Text(decryptedMessage),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return ListView(
                    controller: _scrollController, children: messages);
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final photo =
                        await picker.pickImage(source: ImageSource.camera);
                    if (photo != null) _sendMessage(imagePath: photo.path);
                  }),
              IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) _sendMessage(imagePath: image.path);
                  }),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.writeAMessage),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage()),
            ],
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final Uint8List imageData;

  const FullScreenImage({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.memory(imageData),
      ),
    );
  }
}
