import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String _fontFamily = 'Gaegu';

  static const TextStyle header = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subHeaderRed = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryRed,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    color: AppColors.textPrimary,
  );
}