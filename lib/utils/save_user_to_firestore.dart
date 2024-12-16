import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveUserToFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userData = {
      'name': user.displayName ?? 'Unknown',
      'email': user.email ?? 'Unknown',
    };
    await userDoc.set(userData, SetOptions(merge: true));
    print('✅ Utilizator salvat în Firestore: ${userData['name']}');
  }
}
