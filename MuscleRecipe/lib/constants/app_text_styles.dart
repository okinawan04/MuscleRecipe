import 'package:flutter/material.dart';
import 'app_colors.dart';

/// アプリケーション全体で使用するテキストスタイルの定数
class AppTextStyles {
  // ページタイトル用スタイル（"Muscle memory"など）
  static const TextStyle pageTitle = TextStyle(
    color: AppColors.textPrimaryColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // タブボタン用テキストスタイル
  static const TextStyle tabButtonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ボタンテキストスタイル
  static const TextStyle buttonText = TextStyle(
    color: AppColors.textPrimaryColor,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // グラフ/カレンダータイトルスタイル
  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimaryColor,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // グリッドラベルスタイル
  static const TextStyle gridLabel = TextStyle(
    color: AppColors.textSecondaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );

  // カレンダー月年表示スタイル
  static const TextStyle calendarHeader = TextStyle(
    color: AppColors.textPrimaryColor,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // カレンダー曜日スタイル
  static const TextStyle calendarWeekday = TextStyle(
    color: AppColors.textPrimaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  // カレンダー日付スタイル
  static const TextStyle calendarDay = TextStyle(
    color: AppColors.textPrimaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  // Private constructor to prevent instantiation
  AppTextStyles._();
}
