import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sienna_app/services/auth_service.dart';

class HomePage extends StatelessWidget {
  final String displayName;
  final String fullName;
  final bool isIndonesian;
  const HomePage({
    super.key,
    required this.displayName,
    required this.fullName,
    required this.isIndonesian,
  });
  String get _name {
    if (displayName.isNotEmpty) return displayName;
    if (fullName.isNotEmpty) return fullName.split(' ').first;
    return 'Traveler';
  }
  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (isIndonesian) {
      if (hour >= 5 && hour < 11) return 'Selamat pagi';
      if (hour >= 11 && hour < 15) return 'Selamat siang';
      if (hour >= 15 && hour < 18) return 'Selamat sore';
      return 'Selamat malam';
    }
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const green = Color(0xFF176B59);
    const forest = Color(0xFF233B35);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4EB),
        title: const Text(
          'SIENNA',
          style: TextStyle(
            color: green,
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout,
              color: green,
            ),
            onPressed: () async {
              try {
                await AuthService().signOut();
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout failed.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_timeGreeting()},',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718078),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$_name!',
                style: const TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                  color: forest,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                isIndonesian
                    ? 'Siap menjelajahi Bali hari ini?'
                    : 'Ready to explore Bali today?',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF718078),
                ),
              ),
              const SizedBox(height: 50),
              const Center(
                child: Icon(
                  Icons.explore_outlined,
                  color: green,
                  size: 72,
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Welcome to SIENNA!',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: forest,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Logged in as:\n${user?.email ?? "-"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718078),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Center(
                child: Text(
                  'Explore Bali Home Page\nComing Soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718078),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}