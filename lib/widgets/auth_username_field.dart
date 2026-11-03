import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sienna_app/services/auth_service.dart';
import 'package:sienna_app/widgets/auth_text.dart';

enum _UsernameStatus { idle, checking, available, taken, error }
class AuthUsernameField extends StatefulWidget {
  final TextEditingController controller;
  final bool isIndonesian;
  final bool enabled;
  const AuthUsernameField({
    super.key,
    required this.controller,
    required this.isIndonesian,
    required this.enabled,
  });

  @override
  State<AuthUsernameField> createState() => _AuthUsernameFieldState();
}
class _AuthUsernameFieldState extends State<AuthUsernameField> {
  static const _green = Color(0xFF176B59);
  final _service = AuthService();
  _UsernameStatus _status = _UsernameStatus.idle;
  Timer? _timer;
  int _revision = 0;
  String tr(String id, String en) => widget.isIndonesian ? id : en;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  String? _validate(String? value) {
    final username = value?.trim().toLowerCase() ?? '';
    if (username.isEmpty) {
      return tr('Username wajib diisi', 'Username is required');
    }
    if (!AuthService.usernamePattern.hasMatch(username)) {
      return tr(
        'Gunakan 3-20 karakter: huruf, angka, atau underscore',
        'Use 3-20 letters, numbers, or underscores',
      );
    }
    if (_status == _UsernameStatus.taken) {
      return tr('Username sudah digunakan', 'Username is already taken');
    }
    return null;
  }
  void _onChanged(String value) {
    _timer?.cancel();
    final revision = ++_revision;
    final username = value.trim().toLowerCase();
    if (!AuthService.usernamePattern.hasMatch(username)) {
      setState(() => _status = _UsernameStatus.idle);
      return;
    }
    setState(() => _status = _UsernameStatus.checking);
    _timer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final available = await _service.isUsernameAvailable(username);
        if (!mounted || revision != _revision) return;
        setState(() {
          _status = available
              ? _UsernameStatus.available
              : _UsernameStatus.taken;
        });
      } catch (error) {
        if (!mounted || revision != _revision) return;
        debugPrint('Username availability error: $error');
        setState(() => _status = _UsernameStatus.error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: widget.controller,
          label: 'Username',
          icon: Icons.alternate_email,
          validator: _validate,
          enabled: widget.enabled,
          onChanged: _onChanged,
        ),
        const SizedBox(height: 7),
        _buildStatus(),
      ],
    );
  }
  Widget _buildStatus() {
    switch (_status) {
      case _UsernameStatus.idle:
        return Text(
          tr(
            '3-20 karakter: huruf, angka, atau underscore (_)',
            '3-20 characters: letters, numbers, or underscores (_)',
          ),
          style: const TextStyle(color: Color(0xFF718078), fontSize: 12),
        );
      case _UsernameStatus.checking:
        return _statusRow(
          tr('Memeriksa username...', 'Checking username...'),
          _green,
          isLoading: true,
        );
      case _UsernameStatus.available:
        return _statusRow(
          tr('Username tersedia', 'Username available'),
          _green,
          icon: Icons.check_circle_outline,
        );
      case _UsernameStatus.taken:
        return _statusRow(
          tr('Username sudah digunakan', 'Username already taken'),
          Colors.redAccent,
          icon: Icons.cancel_outlined,
        );
      case _UsernameStatus.error:
        return _statusRow(
          tr(
            'Gagal memeriksa username. Periksa koneksi.',
            'Could not check username. Check your connection.',
          ),
          Colors.deepOrange,
          icon: Icons.warning_amber_rounded,
        );
    }
  }
  Widget _statusRow(
      String message,
      Color color, {
        IconData? icon,
        bool isLoading = false,
      }) {
    return Row(
      children: [
        if (isLoading)
          SizedBox(
            height: 15,
            width: 15,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        else
          Icon(icon, color: color, size: 17),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ),
      ],
    );
  }
}