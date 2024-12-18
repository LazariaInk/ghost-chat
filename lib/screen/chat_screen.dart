import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:typed_data';
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
    final compressedImagePath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressedImageFile = File(compressedImagePath);
    await compressedImageFile.writeAsBytes(compressedImageBytes);
    return compressedImagePath;
  }

  Future<String> _convertImageToBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }

  void _sendMessage({String? imagePath}) async {
    if ((_messageController.text.isNotEmpty || imagePath != null) && _encryptionKey != null) {
      setState(() {});

      try {
        String plainMessage = _messageController.text;
        if (imagePath != null) {
          final compressedImagePath = await _compressImage(imagePath);
          final base64Image = await _convertImageToBase64(compressedImagePath);
          plainMessage = 'image:$base64Image';
        }
        String encryptedMessage = CryptoUtils.encryptMessage(plainMessage, _encryptionKey!);

        final userId = FirebaseAuth.instance.currentUser?.uid;
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final userName = userDoc['name'] ?? 'Anonymous User';

        await FirebaseFirestore.instance.collection('channels').doc(widget.channelName).collection('messages').add({
          'content': encryptedMessage,
          'senderId': userId,
          'senderName': userName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _messageController.clear();
        _scrollToBottom();
      } catch (e) {
        print('Error sending message: $e');
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
                  try {
                    decryptedMessage = CryptoUtils.decryptMessage(encryptedMessage, _encryptionKey!);
                  } catch (e) {
                    print('Error decrypting message: $e');
                  }
                  return ListTile(
                    title: decryptedMessage.startsWith('image:')
                        ? GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FullScreenImage(
                                  imageData: base64Decode(decryptedMessage.substring(6))
                              )
                          )
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: 80,
                          height: 80,
                          child: AspectRatio(
                            aspectRatio:  1,
                            child: Image.memory(
                              base64Decode(decryptedMessage.substring(6)),
                            ),
                          ),
                        ),
                      ),
                    )
                        : Text(decryptedMessage),
                    subtitle: Text(doc['senderName'] ?? 'Unknown User'),
                  );
                }).toList();
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView(controller: _scrollController, children: messages);
              },
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.camera_alt), onPressed: () async {
                final picker = ImagePicker();
                final photo = await picker.pickImage(source: ImageSource.camera);
                if (photo != null) _sendMessage(imagePath: photo.path);
              }),
              IconButton(icon: const Icon(Icons.photo), onPressed: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) _sendMessage(imagePath: image.path);
              }),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(hintText: 'Write a message...'),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: () => _sendMessage()),
            ],
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final Uint8List imageData;

  const FullScreenImage({Key? key, required this.imageData}) : super(key: key);

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
