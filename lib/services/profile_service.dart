import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/userprofile.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;


  Future<void> createProfile(String uid, String email, String name) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'bio': '',
      'photoUrl': '',
    });
  }

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!, uid);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).update(profile.toMap());
  }

  /// Uploads image to Storage, returns download URL
  /*Future<String> uploadPhoto(String uid, File image) async {
    final ref = _storage.ref('avatars/$uid.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  } */
}