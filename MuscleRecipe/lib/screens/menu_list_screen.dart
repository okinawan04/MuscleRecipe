import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/training_models.dart';
import '../providers/training_data_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

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
      body: Container(
        color: AppColors.backgroundColor,
        child: Column(
          children: [
            // Header with date
            Container(
              color: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        DateFormat('yyyy/MM/dd', 'ja_JP')
                            .format(_selectedDate),
                        style: AppTextStyles.calendarHeader,
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.white),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                              _updateCurrentDayTraining();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Statistics
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    '合計種目数',
                    _currentDayTraining.totalMenuCount.toString(),
                  ),
                  _buildStatCard(
                    '合計セット数',
                    _currentDayTraining.totalSetCount.toString(),
                  ),
                  _buildStatCard(
                    '合計レップ数',
                    _currentDayTraining.totalRepCount.toString(),
                  ),
                  _buildStatCard(
                    '合計負荷量',
                    _currentDayTraining.totalWeightLoad.toStringAsFixed(0),
                  ),
                ],
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
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemBuilder: (context, index) {
                        final menu = _currentDayTraining.menus[index];
                        return _buildMenuCard(menu);
                      },
                    ),
            ),
            // Add button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    // Navigate to exercise selection screen
                  },
                  backgroundColor: AppColors.primaryColor,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    '＋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(TrainingMenu menu) {
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
                          '${set.rm!.toStringAsFixed(1)}',
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
