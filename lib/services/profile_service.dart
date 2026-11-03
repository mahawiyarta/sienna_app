import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final FirebaseAuth _auth =
      FirebaseAuth.instance;
  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    if (!document.exists) {
      return null;
    }
    return document.data();
  }
}