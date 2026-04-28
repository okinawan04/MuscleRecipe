import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// ナビゲーションバーアイテムの定義
class NavItem {
  final IconData icon;
  final int index;

  NavItem({
    required this.icon,
    required this.index,
  });
}

/// カスタムボトムナビゲーションバーウィジェット
class CustomBottomNavigationBar extends StatelessWidget {
  /// ナビゲーションアイテムのリスト
  final List<NavItem> items;

  /// 現在選択されているインデックス
  final int selectedIndex;

  /// アイテムタップ時のコールバック
  final Function(int)? onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          items.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 24,
            ),
            child: _buildNavIcon(items[index], index),
          ),
        ),
      ),
    );
  }

  /// ナビゲーションアイコンを構築
  Widget _buildNavIcon(NavItem item, int index) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () {
        onTap?.call(item.index);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          item.icon,
          color: AppColors.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }
}
