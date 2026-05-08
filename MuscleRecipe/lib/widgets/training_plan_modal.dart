import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

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
                  title: '初心者向け',
                  subtitle: '週2〜3回：全身法',
                  description: 'まずはフォームを安定させるプランです。',
                  details: [
                    ['脚・尻', 'スクワット', '10〜12回 × 3'],
                    ['胸', 'プッシュアップ', '10〜12回 × 3'],
                    ['背中', 'ラットプルダウン', '10〜12回 × 3'],
                    ['体幹', 'プランク', '30〜60秒 × 3'],
                  ],
                ),
                const SizedBox(height: 16),
                _PlanCard(
                  title: '中級者向け',
                  subtitle: '週3〜4回：部位分割法',
                  description: '2分割（上半身・下半身）で追い込むプラン。',
                  details: [
                    ['A:胸肩', 'ベンチプレス', '8〜10回 × 3'],
                    ['A:背中', 'ベントオーバーロウ', '8〜10回 × 3'],
                    ['B:脚', 'バーベルスクワット', '8〜10回 × 3'],
                    ['B:腹筋', 'レッグレイズ', '15〜20回 × 3'],
                  ],
                ),
                const SizedBox(height: 16),
                _PlanCard(
                  title: '上級者向け',
                  subtitle: '週5〜6回：高頻度・高強度',
                  description: 'POF法を取り入れ、部位別に極限まで刺激。',
                  details: [
                    ['月', '胸：ベンチ + フライ', 'POF法'],
                    ['火', '背中：デッドリフト', '厚み重視'],
                    ['水', '肩：レイズ + プレス', '丸み重視'],
                    ['木', '脚：スクワット', '強度MAX'],
                  ],
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
  final String title;
  final String subtitle;
  final String description;
  final List<List<String>> details;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.details,
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
            Text(title, style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primaryColor)),
            Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            // メニュー表
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: details.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50, 
                        child: Text(row[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                        ),
                      Expanded(
                        child: 
                        Text(row[0], style: const TextStyle(fontSize: 10))
                        ),
                      Text(
                        row[0],
                        style: const TextStyle(fontSize: 10, color: Colors.grey)
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
                  // TODO: 選択されたプランを保存する処理
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
}