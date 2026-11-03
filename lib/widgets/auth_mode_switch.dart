import 'package:flutter/material.dart';

class AuthModeSwitch extends StatelessWidget {
  final bool isSignUp;
  final bool isIndonesian;
  final VoidCallback? onTap;
  const AuthModeSwitch({
    super.key,
    required this.isSignUp,
    required this.isIndonesian,
    required this.onTap,
  });
  String tr(String id, String en) => isIndonesian ? id : en;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            isSignUp
                ? tr('Sudah punya akun?', 'Already have an account?')
                : tr('Belum punya akun?', "Don't have an account?"),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF233B35),
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            isSignUp ? tr('Masuk', 'Sign In') : tr('Daftar', 'Sign Up'),
            style: const TextStyle(
              color: Color(0xFF176B59),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}