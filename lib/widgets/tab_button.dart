import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// タブボタンウィジェット
class TabButton extends StatelessWidget {
  /// ボタンに表示するテキスト
  final String label;

  /// ボタンが選択されているかどうか
  final bool isSelected;

  /// ボタンタップ時のコールバック
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: AppColors.primaryColor,
                  width: 1,
                ),
        ),
        child: Text(
          label,
          style: AppTextStyles.tabButtonText.copyWith(
            color: isSelected
                ? AppColors.textPrimaryColor
                : AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
