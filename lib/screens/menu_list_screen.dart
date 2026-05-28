import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import 'package:muscle_recipe/database_helper.dart';
import '../models/training_models.dart' as models;
import 'exercise_selection_screen.dart';
import 'menu_creation_screen.dart';
//import '../home.dart';
import '../widgets/training_plan_modal.dart';

class MenuListScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final List<TrainingMenu>? planMenus;
  final TrainingPlan? trainingPlan;
  final List<int>? selectedWeekdays;
  final Map<String, List<TrainingMenu>>? weekdayMenuMap;

  const MenuListScreen({
    super.key,
    this.selectedDate,
    this.planMenus,
    this.trainingPlan,
    this.selectedWeekdays,
    this.weekdayMenuMap,
  });

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  late DateTime _selectedDate;
  List<Map<String, dynamic>> _trainingRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _initialize();
  }

  Future<void> _initialize() async {
    final planAdded = await _addPlanMenusIfProvided();
    await _loadTrainingRecords();
    setState(() {
      _isLoading = false;
    });
    
    if (planAdded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('トレーニングプランを追加しました')),
      );
    }
  }

  Future<bool> _addPlanMenusIfProvided() async {
    try {
      final db = DatabaseHelper.instance;
      final database = await db.database;
      bool planAdded = false;

      if (widget.weekdayMenuMap != null && widget.weekdayMenuMap!.isNotEmpty) {
        for (final entry in widget.weekdayMenuMap!.entries) {
          final dateString = entry.key;
          final menuList = entry.value;

          for (final menu in menuList) {
            final rows = await database.query(
              'training_menus',
              where: 'name = ?',
              whereArgs: [menu.exerciseName],
            );

            if (rows.isNotEmpty) {
              final menuId = rows.first['id'] as int;
              await db.insertTrainingRecord(
                menuId: menuId,
                trainingDate: dateString,
                setNumber: menu.setNumber,
                weight: menu.weight,
                reps: menu.reps,
                memo: menu.memo,
              );
            }
          }
        }
        planAdded = true;
      } else if (widget.planMenus != null && widget.planMenus!.isNotEmpty) {
        for (final menu in widget.planMenus!) {
          final rows = await database.query(
            'training_menus',
            where: 'name = ?',
            whereArgs: [menu.exerciseName],
          );

          if (rows.isNotEmpty) {
            final menuId = rows.first['id'] as int;
            await db.insertTrainingRecord(
              menuId: menuId,
              trainingDate: _selectedDate.toString().split(' ')[0],
              setNumber: menu.setNumber,
              weight: menu.weight,
              reps: menu.reps,
              memo: menu.memo,
            );
          }
        }
        planAdded = true;
      }

      return planAdded;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プラン追加エラー: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _loadTrainingRecords() async {
    try {
      final db = DatabaseHelper.instance;
      final records = await db.getTrainingRecordsByDate(_selectedDate);
      setState(() {
        _trainingRecords = List<Map<String, dynamic>>.from(records);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('データ読み込みエラー: $e')),
      );
      setState(() {
        _isLoading = false;
      });
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
                        onTap: () {
                          Navigator.of(context).pop();
                        } ,
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
                        _getUniqueExerciseCount().toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        '合計セット数',
                        _trainingRecords.length.toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        '合計レップ数',
                        _getTotalReps().toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        '合計負荷量',
                        _getTotalWeight().toStringAsFixed(0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Menu list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _trainingRecords.isEmpty
                      ? const Center(
                          child: Text('今日のトレーニングはまだありません'
                              , style: TextStyle(color: Colors.white70),
                              ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _getGroupedExercises().length,
                          itemBuilder: (context, index) {
                            final exercises = _getGroupedExercises();
                            final exerciseName = exercises.keys.toList()[index];
                            final sets = exercises[exerciseName] ?? [];
                            final bodyPart = _getBodyPartFromCategory(
                              sets.isNotEmpty ? sets.first['category'] as String? : null,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MenuCreationScreen(
                                                exercise: models.Exercise(
                                                  name: exerciseName,
                                                  bodyPart: bodyPart,
                                                ),
                                                date: _selectedDate,
                                                existingRecords: sets,
                                              ),
                                            ),
                                          );
                                          if (result == true && mounted) {
                                            await _loadTrainingRecords();
                                          }
                                        },
                                        child: Center(
                                          child: Text(
                                            exerciseName,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...sets.map((set) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Set ${set['set_number']}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${set['weight']}kg × ${set['reps']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Builder(builder: (context) {
                                                  final weight = (set['weight'] as num?)?.toDouble() ?? 0.0;
                                                  final reps = set['reps'] as int? ?? 0;
                                                  final rm = weight * reps / 40 + weight;
                                                  return Text(
                                                    'RM: ${rm.isFinite ? rm.toStringAsFixed(1) : '0.0'}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primaryColor,
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                            if (set['memo'] != null &&
                                                set['memo'].toString().isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  'メモ: ${set['memo']}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                  // Delete button at top right
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _deleteExerciseSet(
                                        sets.first['menu_id'] as int,
                                        exerciseName,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red[400],
                                          size: 20,
                                        ),
                                      ),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseSelectionScreen(selectedDate: _selectedDate),
            ),
          );

          if (mounted) {
            // リロード
            await _loadTrainingRecords();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  int _getUniqueExerciseCount() {
    final uniqueNames = <String>{};
    for (final record in _trainingRecords) {
      uniqueNames.add(record['name'] as String);
    }
    return uniqueNames.length;
  }

  int _getTotalReps() {
    return _trainingRecords.fold(
      0,
      (sum, record) => sum + (record['reps'] as int),
    );
  }

  double _getTotalWeight() {
    return _trainingRecords.fold(
      0.0,
      (sum, record) {
        final weight = (record['weight'] as num).toDouble();
        final reps = record['reps'] as int;
        return sum + (weight * reps);
      }
    );
  }

  Map<String, List<Map<String, dynamic>>> _getGroupedExercises() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final record in _trainingRecords) {
      final name = record['name'] as String;
      if (!grouped.containsKey(name)) {
        grouped[name] = [];
      }
      grouped[name]!.add(record);
    }
    return grouped;
  }

  models.BodyPart _getBodyPartFromCategory(String? categoryName) {
    return models.BodyPart.values.firstWhere(
      (bp) => bp.displayName == categoryName,
      orElse: () => models.BodyPart.chest,
    );
  }

  Future<void> _deleteExerciseSet(int menuId, String exerciseName) async {
    try {
      final db = DatabaseHelper.instance;
      final dateString = _selectedDate.toIso8601String().split('T')[0];

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('削除確認'),
          content: Text('$exerciseName の全セットを削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                // Delete all sets of this exercise for the selected date
                await db.deleteTrainingRecordsByMenuIdAndDate(menuId, dateString);

                // Remove from UI
                setState(() {
                  _trainingRecords.removeWhere((record) => record['menu_id'] == menuId);
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('種目を削除しました')),
                  );
                }
              },
              child: const Text(
                '削除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除に失敗しました: $e')),
      );
    }
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
