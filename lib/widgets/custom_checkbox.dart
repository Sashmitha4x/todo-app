import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryRed,
            width: 1.3,
          ),
          color: value ? AppColors.primaryRed.withOpacity(0.1) : Colors.transparent,
        ),
        child: value
            ? const Icon(Icons.check, size: 18, color: AppColors.primaryRed)
            : null,
      ),
    );
  }
}