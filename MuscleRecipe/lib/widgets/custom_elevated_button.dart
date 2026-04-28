import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// アプリケーション全体で使用するカスタムボタンウィジェット
class CustomElevatedButton extends StatelessWidget {
  /// ボタンに表示するテキスト
  final String label;

  /// ボタンタップ時のコールバック
  final VoidCallback? onPressed;

  /// ボタンの幅（デフォルトは全幅）
  final double? width;

  /// ボタンの背景色
  final Color backgroundColor;

  const CustomElevatedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
    this.backgroundColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonText,
        ),
      ),
    );
  }
}
