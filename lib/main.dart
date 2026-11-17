import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'pages/profile_page.dart';
import 'pages/home_page.dart';
import 'pages/welcome_page.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIENNA',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B59),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F4EB),
      ),
      home: const AuthGate(),
    );
  }
}
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }
        if (authSnapshot.hasError) {
          return const _GateErrorScaffold(
            message: 'Gagal memeriksa status login.',
          );
        }
        final user = authSnapshot.data;
        if (user == null) return const WelcomePage();
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          key: ValueKey(user.uid),
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScaffold();
            }
            if (profileSnapshot.hasError) {
              return const _GateErrorScaffold(
                message: 'Gagal membaca profil.',
              );
            }
            final document = profileSnapshot.data;
            if (document == null || !document.exists) {
              return const _ProfileDocumentPending();
            }
            final profile = document.data() ?? <String, dynamic>{};
            final isIndonesian = profile['language'] == 'id';
            if (profile['profileCompleted'] == true) {
              return HomePage(
                displayName: (profile['displayName'] as String?)?.trim() ?? '',
                fullName: (profile['fullName'] as String?)?.trim() ?? '',
                isIndonesian: isIndonesian,
              );
            }
            return ProfilePage(isIndonesian: isIndonesian);
          },
        );
      },
    );
  }
}
class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF176B59),
        ),
      ),
    );
  }
}
class _GateErrorScaffold extends StatelessWidget {
  final String message;
  const _GateErrorScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFF176B59),
              ),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => AuthService().signOut(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _ProfileDocumentPending extends StatefulWidget {
  const _ProfileDocumentPending();

  @override
  State<_ProfileDocumentPending> createState() => _ProfileDocumentPendingState();
}
class _ProfileDocumentPendingState extends State<_ProfileDocumentPending> {
  bool _showHint = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showHint = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showHint) return const _LoadingScaffold();
    return const _GateErrorScaffold(
      message: 'Data profil belum ditemukan'
    );
  }
}