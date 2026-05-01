import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/training_models.dart';
import '../providers/training_data_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'exercise_selection_screen.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  late List<DailyTraining> allTrainingData;
  late DateTime _selectedDate;
  late DailyTraining _currentDayTraining;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    allTrainingData = TrainingDataProvider.getSampleTrainingData();
    _updateCurrentDayTraining();
  }

  void _updateCurrentDayTraining() {
    // 選択された日付のデータを取得、なければ空のDailyTrainingを作成
    try {
      _currentDayTraining = allTrainingData.firstWhere(
        (training) =>
            training.date.year == _selectedDate.year &&
            training.date.month == _selectedDate.month &&
            training.date.day == _selectedDate.day,
      );
    } catch (e) {
      _currentDayTraining = DailyTraining(
        date: _selectedDate,
        menus: [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          child: Column(
            children: [
              // Header with date
              Container(
                color: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy/MM/dd', 'ja_JP')
                              .format(_selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 28),
                      ],
                    ),
                  ],
                ),
              ),
              // Statistics
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '合計種目数',
                          _currentDayTraining.totalMenuCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          '合計セット数',
                          _currentDayTraining.totalSetCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          '合計レップ数',
                          _currentDayTraining.totalRepCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          '合計負荷量',
                          _currentDayTraining.totalWeightLoad.toStringAsFixed(0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Menu list
              Expanded(
                child: _currentDayTraining.menus.isEmpty
                    ? Center(
                        child: Text(
                          'メニューが登録されていません',
                          style: AppTextStyles.sectionTitle,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _currentDayTraining.menus.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemBuilder: (context, index) {
                          final menu = _currentDayTraining.menus[index];
                          return _buildMenuCard(menu);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  
                  final selectedExercise = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExerciseSelectionScreen(),
                    ),
                  );

                  // 2. 種目が選択されて戻ってきた場合の処理
                  if (selectedExercise != null && selectedExercise is Exercise) {
                    // TODO: 選択された種目を使って、セット数などを入力する編集画面へ進む
                    print('選択された種目: ${selectedExercise.name}');
                  }

                },
                backgroundColor: AppColors.primaryColor,
                shape: const CircleBorder(), // 丸い形状
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                  ),
              ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(TrainingMenu menu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to menu creation screen
            },
            child: Text(
              menu.exercise.name,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(
              menu.sets.length,
              (index) {
                final set = menu.sets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set ${set.setNumber}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${set.weight.toStringAsFixed(1)}kg × ${set.reps}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (set.rm != null)
                        Text(
                          set.rm!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
