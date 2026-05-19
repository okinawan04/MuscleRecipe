import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../screens/menu_list_screen.dart';

// トレーニングプランのデータモデル
class TrainingPlan {
  final String title;
  final String subtitle;
  final String description;
  final int minDaysPerWeek; // 最小実施日数
  final int maxDaysPerWeek; // 最大実施日数
  final List<PlanMenu> scheduleMenus; // 順序付きのメニューリスト

  TrainingPlan({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.minDaysPerWeek,
    required this.maxDaysPerWeek,
    required this.scheduleMenus,
  });
}

// プランのメニューセット（各日のメニュー）
class PlanMenu {
  final String dayLabel; // 例: "全身A", "胸トレーニング"
  final String? subtitle; // 例: "初心者向け", "POF法"
  final List<TrainingMenu> exercises;

  PlanMenu({
    required this.dayLabel,
    this.subtitle,
    required this.exercises,
  });
}

// トレーニングメニューのデータモデル
class TrainingMenu {
  final String exerciseName;
  final String category; // 例: "胸", "背中"（必要に応じて追加）
  final double weight;
  final int reps;
  final int setNumber;
  final String? memo;

  TrainingMenu({
    required this.exerciseName,
    required this.category,
    required this.weight,
    required this.reps,
    required this.setNumber,
    this.memo,
  });
}
// プランのメニュー定義
final Map<String, TrainingPlan> trainingPlans = {
  'beginner': TrainingPlan(
    title: '初心者向け',
    subtitle: '週2〜3回：全身法',
    description: 'まずはフォームを安定させるプランです。',
    minDaysPerWeek: 2,
    maxDaysPerWeek: 3,
    scheduleMenus: [
      PlanMenu(
        dayLabel: '全身Aメニュー',
        subtitle: '初心者向け',
        exercises: [
          TrainingMenu(exerciseName: 'スクワット', category: '脚', weight: 40, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'スクワット', category: '脚', weight: 40, reps: 12, setNumber: 2),
          TrainingMenu(exerciseName: 'スクワット', category: '脚', weight: 40, reps: 12, setNumber: 3),
          TrainingMenu(exerciseName: 'ショルダープレス', category: '肩', weight: 20, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'ショルダープレス', category: '肩', weight: 20, reps: 12, setNumber: 2),
          TrainingMenu(exerciseName: 'ショルダープレス', category: '肩', weight: 20, reps: 12, setNumber: 3),
        ],
      ),
      PlanMenu(
        dayLabel: '全身Bメニュー',
        subtitle: '初心者向け',
        exercises: [
          TrainingMenu(exerciseName: 'ラットプルダウン', category: '背中', weight: 30, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'ラットプルダウン', category: '背中', weight: 30, reps: 12, setNumber: 2),
          TrainingMenu(exerciseName: 'ラットプルダウン', category: '背中', weight: 30, reps: 12, setNumber: 3),
          TrainingMenu(exerciseName: 'レッグプレス', category: '脚', weight: 40, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'レッグプレス', category: '脚', weight: 40, reps: 12, setNumber: 2),
          TrainingMenu(exerciseName: 'レッグプレス', category: '脚', weight: 40, reps: 12, setNumber: 3),
        ],
      ),
      PlanMenu(
        dayLabel: '全身Cメニュー',
        subtitle: '初心者向け',
        exercises: [
          TrainingMenu(exerciseName: 'ベンチプレス', category: '胸', weight: 30, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'ベンチプレス', category: '胸', weight: 30, reps: 12, setNumber: 2),
          TrainingMenu(exerciseName: 'ベンチプレス', category: '胸', weight: 30, reps: 12, setNumber: 3),
          TrainingMenu(exerciseName: 'インクラインダンベルプレス', category: '胸', weight: 10, reps: 60, setNumber: 1),
          TrainingMenu(exerciseName: 'インクラインダンベルプレス', category: '胸', weight: 10, reps: 60, setNumber: 2),
          TrainingMenu(exerciseName: 'インクラインダンベルプレス', category: '胸', weight: 10, reps: 60, setNumber: 3),
        ],
      ),
    ],
  ),
  'intermediate': TrainingPlan(
    title: '中級者向け',
    subtitle: '週3〜4回：部位分割法',
    description: '2分割（上半身・下半身）で追い込むプラン。',
    minDaysPerWeek: 3,
    maxDaysPerWeek: 4,
    scheduleMenus: [
      PlanMenu(
        dayLabel: '上半身Aメニュー',
        subtitle: '胸・肩中心',
        exercises: [
          TrainingMenu(exerciseName: 'ベンチプレス', category: '胸', weight: 60, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'ベンチプレス', category: '胸', weight: 60, reps: 10, setNumber: 2),
          TrainingMenu(exerciseName: 'ベンチプレス', category: '胸', weight: 60, reps: 10, setNumber: 3),
          TrainingMenu(exerciseName: 'ショルダープレス', category: '肩', weight: 40, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'ショルダープレス', category: '肩', weight: 40, reps: 10, setNumber: 2),
          TrainingMenu(exerciseName: 'ショルダープレス', category: '肩', weight: 40, reps: 10, setNumber: 3),
          TrainingMenu(exerciseName: 'サイドレイズ', category: '肩', weight: 20, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'サイドレイズ', category: '肩', weight: 20, reps: 12, setNumber: 2),
        ],
      ),
      PlanMenu(
        dayLabel: '下半身メニュー',
        subtitle: '脚・お尻中心',
        exercises: [
          TrainingMenu(exerciseName: 'バーベルスクワット', category: '脚', weight: 80, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'バーベルスクワット', category: '脚', weight: 80, reps: 10, setNumber: 2),
          TrainingMenu(exerciseName: 'バーベルスクワット', category: '脚', weight: 80, reps: 10, setNumber: 3),
          TrainingMenu(exerciseName: 'レッグプレス', category: '脚', weight: 60, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'レッグプレス', category: '脚', weight: 60, reps: 10, setNumber: 2),
          TrainingMenu(exerciseName: 'レッグカール', category: '脚', weight: 50, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'レッグカール', category: '脚', weight: 50, reps: 12, setNumber: 2),
        ],
      ),
      PlanMenu(
        dayLabel: '上半身Bメニュー',
        subtitle: '背中・腕中心',
        exercises: [
          TrainingMenu(exerciseName: 'デッドリフト', category: '背中', weight: 100, reps: 8, setNumber: 1),
          TrainingMenu(exerciseName: 'デッドリフト', category: '背中', weight: 100, reps: 8, setNumber: 2),
          TrainingMenu(exerciseName: 'デッドリフト', category: '背中', weight: 100, reps: 8, setNumber: 3),
          TrainingMenu(exerciseName: 'ラットプルダウン', category: '背中', weight: 50, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'ラットプルダウン', category: '背中', weight: 50, reps: 10, setNumber: 2),
          TrainingMenu(exerciseName: 'バーベルカール', category: '腕', weight: 30, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'バーベルカール', category: '腕', weight: 30, reps: 10, setNumber: 2),
        ],
      ),
      PlanMenu(
        dayLabel: 'オプション（弱点補強）',
        subtitle: '選択可能',
        exercises: [
          TrainingMenu(exerciseName: 'インクラインチェストプレス', category: '胸', weight: 50, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'インクラインチェストプレス', category: '胸', weight: 50, reps: 10, setNumber: 2),
          TrainingMenu(exerciseName: 'オーバーヘッドエクステンション', category: '腕', weight: 35, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'オーバーヘッドエクステンション', category: '腕', weight: 35, reps: 12, setNumber: 2),
        ],
      ),
    ],
  ),
  'advanced': TrainingPlan(
    title: '上級者向け',
    subtitle: '週5〜6回：高頻度・高強度',
    description: 'POF法を取り入れ、部位別に極限まで刺激。毎日異なる部位トレ。',
    minDaysPerWeek: 5,
    maxDaysPerWeek: 6,
    scheduleMenus: [
      PlanMenu(
        dayLabel: '胸トレーニング',
        subtitle: 'POF法',
        exercises: [
          TrainingMenu(exerciseName: 'ベンチプレス', category: '胸', weight: 100, reps: 8, setNumber: 1),
          TrainingMenu(exerciseName: 'ベンチプレス', category: '胸', weight: 100, reps: 8, setNumber: 2),
          TrainingMenu(exerciseName: 'ベンチプレス', category: '胸', weight: 100, reps: 8, setNumber: 3),
          TrainingMenu(exerciseName: 'インクラインプレス', category: '胸', weight: 80, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'インクラインプレス', category: '胸', weight: 80, reps: 10, setNumber: 2),
          TrainingMenu(exerciseName: 'ダンベルフライ', category: '胸', weight: 50, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'ダンベルフライ', category: '胸', weight: 50, reps: 12, setNumber: 2),
        ],
      ),
      PlanMenu(
        dayLabel: '背中トレーニング',
        subtitle: '厚み重視',
        exercises: [
          TrainingMenu(exerciseName: 'デッドリフト', category: '背中', weight: 150, reps: 8, setNumber: 1),
          TrainingMenu(exerciseName: 'デッドリフト', category: '背中', weight: 150, reps: 8, setNumber: 2),
          TrainingMenu(exerciseName: 'デッドリフト', category: '背中', weight: 150, reps: 8, setNumber: 3),
          TrainingMenu(exerciseName: 'バーベルロウ', category: '背中', weight: 120, reps: 8, setNumber: 1),
          TrainingMenu(exerciseName: 'バーベルロウ', category: '背中', weight: 120, reps: 8, setNumber: 2),
          TrainingMenu(exerciseName: 'ラットプルダウン', category: '背中', weight: 70, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'ラットプルダウン', category: '背中', weight: 70, reps: 10, setNumber: 2),
        ],
      ),
      PlanMenu(
        dayLabel: '肩トレーニング',
        subtitle: '丸み重視',
        exercises: [
          TrainingMenu(exerciseName: 'ショルダープレス', category: '肩', weight: 70, reps: 8, setNumber: 1),
          TrainingMenu(exerciseName: 'ショルダープレス', category: '肩', weight: 70, reps: 8, setNumber: 2),
          TrainingMenu(exerciseName: 'ショルダープレス', category: '肩', weight: 70, reps: 8, setNumber: 3),
          TrainingMenu(exerciseName: 'サイドレイズ', category: '肩', weight: 40, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'サイドレイズ', category: '肩', weight: 40, reps: 12, setNumber: 2),
          TrainingMenu(exerciseName: 'リアデルトフライ', category: '肩', weight: 30, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'リアデルトフライ', category: '肩', weight: 30, reps: 12, setNumber: 2),
        ],
      ),
      PlanMenu(
        dayLabel: '脚トレーニング',
        subtitle: '強度MAX',
        exercises: [
          TrainingMenu(exerciseName: 'バーベルスクワット', category: '脚', weight: 140, reps: 8, setNumber: 1),
          TrainingMenu(exerciseName: 'バーベルスクワット', category: '脚', weight: 140, reps: 8, setNumber: 2),
          TrainingMenu(exerciseName: 'バーベルスクワット', category: '脚', weight: 140, reps: 8, setNumber: 3),
          TrainingMenu(exerciseName: 'レッグプレス', category: '脚', weight: 100, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'レッグプレス', category: '脚', weight: 100, reps: 10, setNumber: 2),
          TrainingMenu(exerciseName: 'レッグカール', category: '脚', weight: 80, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'レッグカール', category: '脚', weight: 80, reps: 10, setNumber: 2),
        ],
      ),
      PlanMenu(
        dayLabel: '腕トレーニング',
        subtitle: '高容量',
        exercises: [
          TrainingMenu(exerciseName: 'バーベルカール', category: '腕', weight: 50, reps: 8, setNumber: 1),
          TrainingMenu(exerciseName: 'バーベルカール', category: '腕', weight: 50, reps: 8, setNumber: 2),
          TrainingMenu(exerciseName: 'バーベルカール', category: '腕', weight: 50, reps: 8, setNumber: 3),
          TrainingMenu(exerciseName: 'ダンベルカール', category: '腕', weight: 30, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'ダンベルカール', category: '腕', weight: 30, reps: 12, setNumber: 2),
          TrainingMenu(exerciseName: 'トライセプスロープ', category: '腕', weight: 40, reps: 10, setNumber: 1),
          TrainingMenu(exerciseName: 'トライセプスロープ', category: '腕', weight: 40, reps: 10, setNumber: 2),
        ],
      ),
      PlanMenu(
        dayLabel: 'アクセサリー',
        subtitle: '弱点補強',
        exercises: [
          TrainingMenu(exerciseName: 'ケーブルフライ', category: '胸', weight: 50, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'ケーブルフライ', category: '胸', weight: 50, reps: 12, setNumber: 2),
          TrainingMenu(exerciseName: 'フェイスプル', category: '肩', weight: 60, reps: 15, setNumber: 1),
          TrainingMenu(exerciseName: 'フェイスプル', category: '肩', weight: 60, reps: 15, setNumber: 2),
          TrainingMenu(exerciseName: 'レッグエクステンション', category: '脚', weight: 70, reps: 12, setNumber: 1),
          TrainingMenu(exerciseName: 'レッグエクステンション', category: '脚', weight: 70, reps: 12, setNumber: 2),
        ],
      ),
    ],
  ),
};

class TrainingPlanModal {
  // モーダルを表示するための静的メソッド
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TrainingPlanContent(),
    );
  }
}

class _TrainingPlanContent extends StatelessWidget {
  const _TrainingPlanContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 上部のバー（ドラッグできることを示すインジケーター）
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('トレーニングプラン選択', style: AppTextStyles.sectionTitle),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PlanCard(
                  plan: trainingPlans['beginner']!,
                ),
                const SizedBox(height: 16),
                _PlanCard(
                  plan: trainingPlans['intermediate']!,
                ),
                const SizedBox(height: 16),
                _PlanCard(
                  plan: trainingPlans['advanced']!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final TrainingPlan plan;

  const _PlanCard({
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gridLineColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.title, style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primaryColor)),
            Text(plan.subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(plan.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            // メニュー表
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: plan.scheduleMenus.map((menu) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menu.dayLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (menu.subtitle != null)
                              Text(
                                menu.subtitle!,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showDateSelectionDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('このプランを選択', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateSelectionDialog(BuildContext context) {
    const dayNames = ['日', '月', '火', '水', '木', '金', '土'];
    final selectedDays = <int>[]; // 選択された曜日（順序付き）

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title: Text(
            '実施する曜日を選択\n(${plan.minDaysPerWeek}～${plan.maxDaysPerWeek}日)',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '選択した順序でメニューが割り当てられます',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(7, (index) {
                    final dayName = dayNames[index];
                    final isSelected = selectedDays.contains(index);
                    final selectionOrder = selectedDays.indexOf(index) + 1;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedDays.remove(index);
                            } else if (selectedDays.length <
                                plan.maxDaysPerWeek) {
                              selectedDays.add(index);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true &&
                                        selectedDays.length <
                                            plan.maxDaysPerWeek) {
                                      selectedDays.add(index);
                                    } else if (value == false) {
                                      selectedDays.remove(index);
                                    }
                                  });
                                },
                                activeColor: Colors.white,
                              ),
                              Expanded(
                                child: Text(
                                  '$dayName曜日',
                                  style:
                                      AppTextStyles.sectionTitle.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    '$selectionOrder',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'キャンセル',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
                    TextButton(
              onPressed: selectedDays.length >= plan.minDaysPerWeek
                  ? () {
                      Navigator.pop(context);
                      _navigateToMenuListScreenForMultipleDays(
                        context,
                        selectedDays,
                      );
                    }
                  : null,
              child: Text(
                '決定',
                style: AppTextStyles.buttonText.copyWith(
                  color: selectedDays.length >= plan.minDaysPerWeek
                      ? AppColors.primaryColor
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _navigateToMenuListScreenForMultipleDays(
    BuildContext context,
    List<int> selectedWeekdays,
  ) {
    final today = DateTime.now();
    final selectedDates = selectedWeekdays
        .map((weekday) => _nextDateForWeekday(today, weekday))
        .toList();

    final Map<String, List<TrainingMenu>> weekdayMenuMap = {};
    for (var i = 0; i < selectedDates.length; i++) {
      if (i < plan.scheduleMenus.length) {
        final dateKey = selectedDates[i].toString().split(' ')[0];
        weekdayMenuMap[dateKey] = plan.scheduleMenus[i].exercises;
      }
    }

    final firstSelectedDate = selectedDates.first;
    final firstDateKey = firstSelectedDate.toString().split(' ')[0];
    final firstDayMenus = weekdayMenuMap[firstDateKey] ?? [];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuListScreen(
          selectedDate: firstSelectedDate,
          planMenus: firstDayMenus,
          trainingPlan: plan,
          selectedWeekdays: selectedWeekdays,
          weekdayMenuMap: weekdayMenuMap,
        ),
      ),
    );
  }

  DateTime _nextDateForWeekday(DateTime from, int weekday) {
    final targetWeekday = weekday == 0 ? 7 : weekday;
    final currentWeekday = from.weekday;
    final offset = (targetWeekday - currentWeekday + 7) % 7;
    return from.add(Duration(days: offset));
  }
}
