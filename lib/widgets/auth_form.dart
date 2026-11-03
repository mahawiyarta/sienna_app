import 'package:flutter/material.dart';
import 'package:sienna_app/services/auth_service.dart';
import 'package:sienna_app/widgets/auth_text.dart';
import 'package:sienna_app/widgets/auth_username_field.dart';

class AuthForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool isSignUp;
  final bool isIndonesian;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onResetPassword;
  const AuthForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.isSignUp,
    required this.isIndonesian,
    required this.isLoading,
    required this.onSubmit,
    required this.onResetPassword,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}
class _AuthFormState extends State<AuthForm> {
  static const _green = Color(0xFF176B59);
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String tr(String id, String en) => widget.isIndonesian ? id : en;
  String? _validateUsernameForSignIn(String? value) {
    final username = value?.trim().toLowerCase() ?? '';
    if (username.isEmpty) {
      return tr('Username wajib diisi', 'Username is required');
    }
    if (!AuthService.usernamePattern.hasMatch(username)) {
      return tr('Format username tidak valid', 'Invalid username format');
    }
    return null;
  }
  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return tr('Email wajib diisi', 'Email is required');
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return tr('Format email tidak valid', 'Invalid email address');
    }
    return null;
  }
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return tr('Password wajib diisi', 'Password is required');
    }
    if (widget.isSignUp && value.length < 6) {
      return tr('Password minimal 6 karakter', 'Password must have at least 6 characters');
    }
    return null;
  }
  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return tr('Konfirmasi password wajib diisi', 'Please confirm your password');
    }
    if (value != widget.passwordController.text) {
      return tr('Password tidak sama', 'Passwords do not match');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isSignUp) ...[
            AuthUsernameField(
              controller: widget.usernameController,
              isIndonesian: widget.isIndonesian,
              enabled: !widget.isLoading,
            ),
            const SizedBox(height: 16),
          ] else ...[
            AuthTextField(
              controller: widget.usernameController,
              label: 'Username',
              icon: Icons.alternate_email,
              enabled: !widget.isLoading,
              autofillHints: const [AutofillHints.username],
              validator: _validateUsernameForSignIn,
            ),
            const SizedBox(height: 16),
          ],
          if (widget.isSignUp) ...[
            AuthTextField(
              controller: widget.emailController,
              label: tr('Alamat Email', 'Email Address'),
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: _validateEmail,
              enabled: !widget.isLoading,
            ),
            const SizedBox(height: 16),
          ],
          AuthTextField(
            controller: widget.passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: !_showPassword,
            autofillHints: [
              widget.isSignUp
                  ? AutofillHints.newPassword
                  : AutofillHints.password,
            ],
            enabled: !widget.isLoading,
            validator: _validatePassword,
            onVisibilityToggle: () {
              setState(() => _showPassword = !_showPassword);
            },
          ),
          if (widget.isSignUp) ...[
            const SizedBox(height: 16),
            AuthTextField(
              controller: widget.confirmController,
              label: tr('Konfirmasi Password', 'Confirm Password'),
              icon: Icons.lock_reset_outlined,
              obscureText: !_showConfirmPassword,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !widget.isLoading,
              validator: _validateConfirm,
              onVisibilityToggle: () {
                setState(() => _showConfirmPassword = !_showConfirmPassword);
              },
            ),
            const SizedBox(height: 24),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isLoading ? null : widget.onResetPassword,
                child: Text(
                  tr('Lupa Password?', 'Forgot Password?'),
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                height: 23,
                width: 23,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                widget.isSignUp
                    ? tr('Buat Akun', 'Create Account')
                    : tr('Masuk', 'Sign In'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}