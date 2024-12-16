import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/dialog_utils.dart';
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
            User? user = await signInWithGoogle(context);
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

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          print('✅ Autentificare reușită pentru UID: ${user.uid}');
          await saveUserToFirestore(user);
        }

        return user;
      }
    } catch (e) {
      DialogUtils.showErrorDialog(
        context,
        'Eroare la autentificare',
        'Verificati conectiunea',
      );
    }
    return null;
  }

  Future<void> saveUserToFirestore(User user) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userData = {
      'name': user.displayName ?? 'User ${user.uid.substring(0, 6)}',
      'email': user.email ?? 'No Email',
    };

    await userDocRef.set(userData, SetOptions(merge: true));
    print('✅ Utilizator salvat în Firestore: ${userData['name']}');
  }
}
