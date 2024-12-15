import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import pentru AppLocalizations
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 Import pentru Firestore

import 'main_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signIn),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = await signInWithGoogle();
            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ),
              );
            }
          },
          child: Text(AppLocalizations.of(context)!.signIn),
        ),
      ),
    );
  }

  /// 🔥 Funcția de autentificare Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          print('✅ Autentificare reușită pentru UID: ${user.uid}');
          await saveUserToFirestore(user); // Salvăm utilizatorul în Firestore
        }

        return user;
      }
    } catch (e) {
      print('❌ Eroare la autentificare Google: $e');
    }
    return null;
  }


  /// 🔥 Funcția de salvare a utilizatorului în Firestore
  Future<void> saveUserToFirestore(User user) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userData = {
      'name': user.displayName ?? 'User ${user.uid.substring(0, 6)}', // Numele implicit
      'email': user.email ?? 'No Email',
    };

    // Adaugă sau actualizează utilizatorul în Firestore
    await userDocRef.set(userData, SetOptions(merge: true)); // Folosim merge pentru a nu suprascrie datele existente
    print('✅ Utilizator salvat în Firestore: ${userData['name']}');
  }
}
