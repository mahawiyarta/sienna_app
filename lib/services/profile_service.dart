import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'geonames_service.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final document = await _firestore.collection('users').doc(user.uid).get();
    return document.data();
  }

  Future<void> completeProfile({
    required String fullName,
    required String nickname,
    required CityLocation? originCity,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User belum login.');
    }
    final cleanFullName = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    final cleanNickname = nickname.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleanFullName.length < 2 || cleanFullName.length > 80) {
      throw const FormatException('Nama lengkap harus 2–80 karakter.');
    }
    if (cleanNickname.length > 40) {
      throw const FormatException('Nama panggilan terlalu panjang.');
    }
    final displayName = cleanNickname.isNotEmpty
        ? cleanNickname
        : cleanFullName.split(' ').first;
    await _firestore.collection('users').doc(user.uid).update({
      'fullName': cleanFullName,
      'displayName': displayName,
      'originCity': originCity?.name,
      'originCountry': originCity?.countryName,
      'originCountryCode': originCity?.countryCode,
      'originGeoNameId': originCity?.geoNameId,
      'profileCompleted': true,
      'profileUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}