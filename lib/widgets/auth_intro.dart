import 'package:flutter/material.dart';

class AuthIntro extends StatelessWidget {
  final bool isSignUp;
  final bool isIndonesian;
  const AuthIntro({
    super.key,
    required this.isSignUp,
    required this.isIndonesian,
  });
  String tr(String id, String en) => isIndonesian ? id : en;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSignUp
              ? tr('Buat Akun', 'Create Account')
              : tr('Selamat Datang Kembali!', 'Welcome Back!'),
          style: const TextStyle(
            color: Color(0xFF233B35),
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSignUp
              ? tr(
            'Buat akun untuk memulai perjalanan bersama SIENNA.',
            'Create an account to explore Bali with SIENNA.',
          )
              : tr(
            'Masuk untuk melanjutkan perjalananmu.',
            'Sign in to continue your journey.',
          ),
          style: const TextStyle(
            color: Color(0xFF718078),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}