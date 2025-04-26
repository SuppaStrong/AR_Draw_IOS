// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ArDrawTheme {
  static const Color primary = Color(0xFF6A3DE8);
  static const Color secondary = Color(0xFF3CCFB2);
  static const Color accent = Color(0xFFFF7D54);
  static const Color success = Color(0xFF58CD78);

  static const Color background = Color(0xFFF7F9FC);
  static const Color cardBg = Colors.white;
  static const Color darkCardBg = Color(0xFFEEF2F7);

  static const Color textPrimary = Color(0xFF242937);
  static const Color textSecondary = Color(0xFF646A7E);
  static const Color textLight = Color(0xFF9DA4BD);

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF242937).withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: const Color(0xFF242937).withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
