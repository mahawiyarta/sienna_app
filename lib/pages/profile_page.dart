import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sienna_app/services/auth_service.dart';
import 'package:sienna_app/services/geonames_service.dart';
import 'package:sienna_app/services/profile_service.dart';
import 'package:sienna_app/widgets/city_field.dart';

class ProfilePage extends StatefulWidget {
  final bool isIndonesian;
  const ProfilePage({super.key, required this.isIndonesian});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  static const _green = Color(0xFF176B59);
  static const _ivory = Color(0xFFF7F4EB);
  static const _forest = Color(0xFF233B35);
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _nickname = TextEditingController();
  final _profileService = UserProfileService();
  CityLocation? _originCity;
  bool _saving = false;
  String tr(String id, String en) => widget.isIndonesian ? id : en;

  @override
  void dispose() {
    _fullName.dispose();
    _nickname.dispose();
    super.dispose();
  }
  String? _validateFullName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) return tr(
      'Nama lengkap wajib diisi.',
      'Full name is required.',
    );
    if (name.length < 2 || name.length > 80) {
      return tr(
        'Gunakan 2–80 karakter.',
        'Use 2–80 characters.',
      );
    }
    return null;
  }
  String? _validateNickname(String? value) {
    if ((value ?? '').trim().length > 40) {
      return tr(
        'Maksimal 40 karakter.',
        'Maximum 40 characters.',
      );
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await _profileService.completeProfile(
        fullName: _fullName.text,
        nickname: _nickname.text,
        originCity: _originCity,
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      final message = error.code == 'permission-denied'
          ? tr(
          'Akses ditolak. Periksa Firestore Security Rules untuk update users/{uid}.',
          'Permission denied. Check Firestore rules for updates to users/{uid}.')
          : tr(
          'Gagal menyimpan profil. Periksa internet dan Firestore.',
          'Could not save your profile. Check internet and Firestore.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr(
            'Gagal menyimpan profil: $error',
            'Could not save profile: $error'),
        ),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(
      icon,
      color: _green,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 17,
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE0E5DF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: _green,
        width: 1.5,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ivory,
      appBar: AppBar(
        backgroundColor: _ivory,
        centerTitle: true,
        title: const Text('SIENNA', style: TextStyle(
          fontFamily: 'serif',
          color: _green,
          fontWeight: FontWeight.bold,
        ),),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _saving ? null : () => AuthService().signOut(),
            child: Text(tr(
              'Keluar',
              'Sign out',
            ),
                style: const TextStyle(color: _green)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 39,
                  backgroundColor: Color(0xFFE2EEE7),
                  child: Icon(
                    Icons.person_outline,
                    size: 40,
                    color: _green,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  tr(
                    'Lengkapi Profilmu',
                    'Complete Your Profile',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: _forest,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    'Kenalan sebentar, lalu mulai jelajahi Bali!',
                    'A quick introduction before you explore Bali!',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF65776E),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _fullName,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  validator: _validateFullName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                    tr('Nama Lengkap *', 'Full Name *'),
                    Icons.badge_outlined,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _nickname,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateNickname,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                      tr(
                        'Nama Panggilan (opsional)',
                        'Nickname (optional)',
                      ),
                      Icons.face_outlined),
                ),
                const SizedBox(height: 7),
                Text(
                  tr(
                    'Nama ini akan muncul di sapaan Home Page.',
                    'This name will appear in your Home Page greeting.',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF718078),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                CityField(
                  isIndonesian: widget.isIndonesian,
                  enabled: !_saving,
                  onSelected: (city) => _originCity = city,
                ),
                const SizedBox(height: 31),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      tr(
                        'Simpan & Jelajahi Bali',
                        'Save & Explore Bali',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  tr(
                    'Data profil disimpan dengan aman di Cloud Firestore.',
                    'Your profile is saved in Cloud Firestore.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF718078),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}