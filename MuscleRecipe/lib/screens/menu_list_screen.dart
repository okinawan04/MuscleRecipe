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
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16), // 左右に余白を追加
                itemCount: _currentDayTraining.menus.length,
                itemBuilder: (context, index) {
                  final menu = _currentDayTraining.menus[index];
                  
                  // ↓ 単なる ListTile ではなく、白い Container で囲う
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu.exercise.name,
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // セットごとの情報を表示
                        ...menu.sets.map((set) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Set ${set.setNumber}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('${set.weight}kg × ${set.reps}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 右下に指定
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExerciseSelectionScreen(),
            ),
          );

          if (result != null) {
            setState(() {
              final exercise = result['exercise'] as Exercise;
              final sets = result['sets'] as List<TrainingSet>;
              final restTime = result['restTime'] as int;

              _currentDayTraining.menus.add(
                TrainingMenu(
                  id: DateTime.now().toString(),
                  date: _selectedDate,
                  exercise: exercise,
                  sets: sets,
                  restTime: restTime,
                ),
              );
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white), // アイコンを白に
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
}
