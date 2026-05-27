import 'package:firebase_auth/firebase_auth.dart';
import 'profile_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential> signUp(String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
    // Create empty profile doc in Firestore
    await ProfileService().createProfile(cred.user!.uid, email, name);
    return cred;
  }

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => _auth.signOut();
}