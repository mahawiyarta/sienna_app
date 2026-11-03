import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sienna_app/widgets/language_button.dart';
import 'auth_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}
class _WelcomePageState extends State<WelcomePage> {
  static const Color primaryGreen = Color(0xFF176B59);
  static const Color ivory = Color(0xFFF7F4EB);
  bool isIndonesian = false;
  void _goToAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthPage(
          isIndonesian: isIndonesian,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ivory,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.40),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.30, 0.65, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              bottom: 180 + bottomPadding,
              child: Align(
                alignment: const Alignment(0, 0.30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF105B49)
                          .withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isIndonesian
                              ? 'Selamat Datang di'
                              : 'Welcome to',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'SIENNA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 53,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isIndonesian
                              ? 'Jelajahi Bali, Sesuai Gayamu.'
                              : 'Explore Bali, Your Way.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          isIndonesian
                              ? 'Aplikasi Rekomendasi Perjalanan '
                              'Cerdas dan Personal untuk Wisata '
                              'Ramah Muslim di Bali.'
                              : 'Your Smart Personalized Travel '
                              'Recommendation Application for '
                              'Muslim-Friendly Tourism in Bali.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 18,
                  bottom: bottomPadding + 20,
                ),
                decoration: const BoxDecoration(
                  color: ivory,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _goToAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          isIndonesian
                              ? 'Mulai Jelajah'
                              : 'Get Started',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LanguageButton(
                            flag: '🇮🇩',
                            label: 'Indonesia',
                            selected: isIndonesian,
                            onTap: () {
                              setState(() {
                                isIndonesian = true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LanguageButton(
                            flag: '🇬🇧',
                            label: 'English',
                            selected: !isIndonesian,
                            onTap: () {
                              setState(() {
                                isIndonesian = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}