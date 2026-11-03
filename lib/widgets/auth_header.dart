import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final VoidCallback? onBack;
  const AuthHeader({super.key, this.onBack});
  static const _green = Color(0xFF176B59);
  static const _gold = Color(0xFFD7AC64);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: double.infinity,
        height: 190,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/welcome.jpg', fit: BoxFit.cover),
            Container(color: _green.withValues(alpha: 0.70)),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_outlined, color: _gold, size: 34),
                  SizedBox(height: 8),
                  Text(
                    'SIENNA',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 39,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Explore Bali, Your Way.',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 6,
              top: 6,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}