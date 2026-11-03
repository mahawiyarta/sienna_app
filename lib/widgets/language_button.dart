import 'package:flutter/material.dart';

class LanguageButton extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const LanguageButton({
    super.key,
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  static const Color primaryGreen = Color(0xFF176B59);
  static const Color forest = Color(0xFF233B35);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? Colors.white
            : const Color(0xFFF0ECE3),
        foregroundColor: forest,
        side: BorderSide(
          color: selected
              ? primaryGreen
              : const Color(0xFFE0DBD1),
          width: selected ? 1.5 : 1,
        ),
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            flag,
            style: const TextStyle(fontSize: 19),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}