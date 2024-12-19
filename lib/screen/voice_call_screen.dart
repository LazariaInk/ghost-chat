import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VoiceCallScreen extends StatefulWidget {
  final String channelName;

  const VoiceCallScreen({super.key, required this.channelName});

  @override
  _VoiceCallScreenState createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  late DateTime _callStartTime;
  late Timer _timer;
  String _callDuration = "00:00";

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCallTimer() {
    _callStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = now.difference(_callStartTime);
      final minutes = difference.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = difference.inSeconds.remainder(60).toString().padLeft(2, '0');
      setState(() {
        _callDuration = "$minutes:$seconds";
      });
    });
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.call ?? 'Call in Progress'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              widget.channelName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _callDuration,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _endCall,
              icon: const Icon(Icons.call_end, color: Colors.white),
              label: Text(AppLocalizations.of(context)?.endCall ?? 'End Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
