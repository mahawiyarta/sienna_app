import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class UsernameTakenException implements Exception {
  const UsernameTakenException();
}
class LoginApiException implements Exception {
  final int statusCode;
  const LoginApiException(this.statusCode);
}
class BackendConnectionException implements Exception {
  const BackendConnectionException();
}
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _baseUrl = 'http://10.0.2.2:3000';
  static final RegExp usernamePattern =
  RegExp(r'^[a-z0-9_]{3,20}$');
  String normalizeUsername(String username) =>
      username.trim().toLowerCase();

  Future<bool> isUsernameAvailable(String username) async {
    final normalized = normalizeUsername(username);
    if (!usernamePattern.hasMatch(normalized)) return false;
    final document = await _firestore
        .collection('usernames')
        .doc(normalized)
        .get();
    return !document.exists;
  }

  Future<UserCredential> signUpWithUsername({
    required String username,
    required String email,
    required String password,
    required String language,
  }) async {
    final normalized = normalizeUsername(username);
    if (!usernamePattern.hasMatch(normalized)) {
      throw const FormatException('Invalid username format');
    }
    if (!await isUsernameAvailable(normalized)) {
      throw const UsernameTakenException();
    }
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase user was not created');
    }
    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(user.uid), {
      'username': normalized,
      'email': user.email,
      'language': language,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.collection('usernames').doc(normalized), {
      'taken': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    try {
      await batch.commit();
      return credential;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied' ||
          error.code == 'already-exists') {
        try {
          await user.delete();
        } catch (_) {
          await _auth.signOut();
        }
      } else {
        await _auth.signOut();
      }
      rethrow;
    }
  }

  Future<UserCredential> signInWithUsername({
    required String username,
    required String password,
  }) async {
    final normalized = normalizeUsername(username);
    if (!usernamePattern.hasMatch(normalized)) {
      throw const FormatException('Invalid username format');
    }
    late final http.Response response;
    try {
      response = await http
          .post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': normalized,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const BackendConnectionException();
    } on SocketException {
      throw const BackendConnectionException();
    } on http.ClientException {
      throw const BackendConnectionException();
    }
    if (response.statusCode != 200) {
      throw LoginApiException(response.statusCode);
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const BackendConnectionException();
    }
    if (decoded is! Map) {
      throw const BackendConnectionException();
    }
    final data = Map<String, dynamic>.from(decoded);
    final token = data['customToken'];
    if (data['success'] != true || token is! String || token.isEmpty) {
      throw const BackendConnectionException();
    }
    return _auth.signInWithCustomToken(token);
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();
}