import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sienna_app/services/auth_service.dart';
import 'package:sienna_app/widgets/auth_form.dart';
import 'package:sienna_app/widgets/auth_header.dart';
import 'package:sienna_app/widgets/auth_intro.dart';
import 'package:sienna_app/widgets/auth_mode_switch.dart';

class AuthPage extends StatefulWidget {
  final bool isIndonesian;
  const AuthPage({super.key, this.isIndonesian = false});

  @override
  State<AuthPage> createState() => _AuthPageState();
}
class _AuthPageState extends State<AuthPage> {
  static const _ivory = Color(0xFFF7F4EB);
  static const _forest = Color(0xFF233B35);
  final _service = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String tr(String id, String en) => widget.isIndonesian ? id : en;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _forest,
        ),
      );
  }
  String _firebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return tr('Email sudah terdaftar.', 'This email is already registered.');
      case 'weak-password':
        return tr('Password terlalu lemah.', 'The password is too weak.');
      case 'invalid-email':
        return tr('Alamat email tidak valid.', 'Invalid email address.');
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return tr('Kredensial tidak valid.', 'Invalid credentials.');
      case 'network-request-failed':
        return tr('Periksa koneksi internet.', 'Check your internet connection.');
      case 'operation-not-allowed':
        return tr('Metode login belum aktif.', 'Sign-in method is not enabled.');
      case 'too-many-requests':
        return tr('Terlalu banyak percobaan. Coba nanti.', 'Too many attempts. Try later.');
      default:
        return tr('Terjadi kesalahan. Coba kembali.', 'Something went wrong. Please try again.');
    }
  }

  Future<void> _submit() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      final password = _passwordController.text;
      if (_isSignUp) {
        await _service.signUpWithUsername(
          username: _usernameController.text,
          email: _emailController.text.trim(),
          password: password,
          language: widget.isIndonesian ? 'id' : 'en',
        );
      } else {
        await _service.signInWithUsername(
          username: _usernameController.text,
          password: password,
        );
      }
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on UsernameTakenException {
      _showMessage(tr('Username sudah digunakan.', 'Username already taken.'));
    } on LoginApiException catch (error) {
      if (error.statusCode == 400 || error.statusCode == 401) {
        _showMessage(tr(
          'Username atau password salah.',
          'Incorrect username or password.',
        ));
      } else if (error.statusCode == 429) {
        _showMessage(tr(
          'Terlalu banyak percobaan login. Coba lagi nanti.',
          'Too many login attempts. Please try again later.',
        ));
      } else {
        _showMessage(tr(
          'Layanan login sedang bermasalah. Periksa backend.',
          'Login service is unavailable. Check the backend.',
        ));
      }
    } on BackendConnectionException {
      _showMessage(tr(
        'Tidak dapat terhubung ke backend SIENNA. Pastikan Node.js berjalan.',
        'Cannot connect to SIENNA backend. Make sure Node.js is running.',
      ));
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase Auth error: ${error.code}');
      _showMessage(_firebaseError(error.code));
    } on FirebaseException catch (error) {
      debugPrint('Firebase/Firestore error: ${error.code}');
      _showMessage(tr('Gagal memproses data akun. Periksa Firebase dan koneksi.',
          'Could not process account. Check Firebase and your connection.'));
    } on FormatException {
      _showMessage(tr('Format username tidak valid.', 'Invalid username format.'));
    } catch (error) {
      debugPrint('Authentication error: $error');
      _showMessage(tr('Gagal memproses permintaan.', 'Unable to process your request.'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_isLoading) return;
    final emailController = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('Reset Password', 'Reset Password')),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: InputDecoration(
            labelText: tr('Email yang didaftarkan', 'Registered email address'),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(tr('Batal', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(emailController.text.trim()),
            child: Text(tr('Kirim', 'Send')),
          ),
        ],
      ),
    );
    emailController.dispose();
    if (!mounted || email == null) return;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage(tr('Masukkan alamat email yang valid.', 'Enter a valid email address.'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _service.resetPassword(email);
      _showMessage(tr('Jika email terdaftar, instruksi reset akan dikirim.',
          'If the email is registered, reset instructions will be sent.'));
    } on FirebaseAuthException catch (error) {
      _showMessage(_firebaseError(error.code));
    } catch (error) {
      debugPrint('Password reset error: $error');
      _showMessage(tr('Gagal mengirim permintaan reset.', 'Could not send reset request.'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  void _switchMode() {
    if (_isLoading) return;
    _formKey.currentState?.reset();
    setState(() {
      _isSignUp = !_isSignUp;
      _usernameController.clear();
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ivory,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                onBack: _isLoading ? null : () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 28),
              AuthIntro(
                isSignUp: _isSignUp,
                isIndonesian: widget.isIndonesian,
              ),
              const SizedBox(height: 26),
              AuthForm(
                key: ValueKey(_isSignUp),
                formKey: _formKey,
                usernameController: _usernameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmController: _confirmController,
                isSignUp: _isSignUp,
                isIndonesian: widget.isIndonesian,
                isLoading: _isLoading,
                onSubmit: _submit,
                onResetPassword: _resetPassword,
              ),
              const SizedBox(height: 22),
              AuthModeSwitch(
                isSignUp: _isSignUp,
                isIndonesian: widget.isIndonesian,
                onTap: _isLoading ? null : _switchMode,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'SIENNA • Explore Bali, Your Way.',
                  style: TextStyle(
                    color: _forest.withValues(alpha: 0.50),
                    fontSize: 12,
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