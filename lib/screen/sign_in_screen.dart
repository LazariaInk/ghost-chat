import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'main_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
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
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }

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

        return userCredential.user;
      }
    } catch (e) {
      print('Eroare la autentificare Google: $e');
    }
    return null;
  }
}
