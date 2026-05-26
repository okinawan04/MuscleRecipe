import 'package:flutter/material.dart';
import '../models/training_models.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'menu_creation_screen.dart';
import '../database_helper.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const ExerciseSelectionScreen({super.key, this.selectedDate});

  @override
  State<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  List<Exercise> allExercises = [];
  Map<BodyPart, List<Exercise>> exercisesByBodyPart = {};
  final Map<BodyPart, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
    _loadExercises(); // Load exercises from the database

    // Initialize expanded state
    for (final bodyPart in BodyPart.values) {
      _expandedState[bodyPart] = false;
    }
  }

  // DBから種目を取得して画面を更新するメソッド
Future<void> _loadExercises() async {
  final dbExercises = await DatabaseHelper.instance.getExercises();
  
  setState(() {
    allExercises = dbExercises.map((map) => Exercise.fromMap(map)).toList();
    _groupExercises(); // 部位ごとに振り分け
  });
}

  void _groupExercises() {
    exercisesByBodyPart = {};
    for (final bodyPart in BodyPart.values) {
      var exercises = allExercises
          .where((e) => e.bodyPart == bodyPart)
          .toList();
      // Sort by creation date (newest first)
      exercises.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // 重複排除：同じ名前の種目は最初の1つだけを保持
      final seenNames = <String>{};
      exercises = exercises.where((e) {
        if (seenNames.contains(e.name)) {
          return false;
        }
        seenNames.add(e.name);
        return true;
      }).toList();
      
      exercisesByBodyPart[bodyPart] = exercises;
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
              // Header
              Container(
                color: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      '種目を選択',
                      style: AppTextStyles.calendarHeader.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              // Add exercise button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showAddExerciseDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '部位・種目を追加',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              // Exercise cards by body part
              Expanded(
                child: ListView.builder(
                  itemCount: BodyPart.values.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemBuilder: (context, index) {
                    final bodyPart = BodyPart.values[index];
                    return _buildBodyPartCard(bodyPart);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyPartCard(BodyPart bodyPart) {
    final exercises = exercisesByBodyPart[bodyPart] ?? [];
    final isExpanded = _expandedState[bodyPart] ?? false;
    final displayCount = isExpanded ? exercises.length : 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body part header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bodyPart.displayName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${exercises.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Exercise list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: List.generate(
                displayCount.clamp(0, exercises.length),
                (index) {
                  final exercise = exercises[index];
                  return _buildExerciseItem(exercise);
                },
              ),
            ),
          ),
          // Show all / Add button row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (exercises.length > 5)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedState[bodyPart] =
                            !_expandedState[bodyPart]!;
                      });
                    },
                    child: Text(
                      isExpanded ? '折りたたむ' : 'すべて表示',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    _showAddExerciseForBodyPartDialog(bodyPart);
                  },
                  child: const Text(
                    '種目を追加',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    return GestureDetector(
      onTap: () async {
        // Navigate to MenuCreationScreen with the selected exercise
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => MenuCreationScreen(
              exercise: exercise,
              date: widget.selectedDate ?? DateTime.now(), // Use selected date or current date
            ),
          ),
        );

        if(result == true && mounted) {
          // If the menu was created successfully, pop back to the previous screen
          Navigator.pop(context, true);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
        child: Center(
        child: Text(
            exercise.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExerciseDialog() {
    String newExerciseName = '';
    BodyPart? selectedBodyPart;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title: const Text(
            '部位・種目を追加',
            style: AppTextStyles.pageTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Body part dropdown
              DropdownButton<BodyPart>(
                value: selectedBodyPart,
                hint: const Text(
                  '部位を選択',
                  style: TextStyle(color: Colors.white70)
                ),
                iconEnabledColor: Colors.white,
                items: BodyPart.values
                    .map((bp) => DropdownMenuItem(
                          value: bp,
                          child: Text(bp.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBodyPart = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Exercise name input
              TextField(
                style: const TextStyle(color: Colors.white), // ★入力された文字を白に
                onChanged: (value) {
                  newExerciseName = value;
                },
                decoration: InputDecoration(
                  hintText: '種目名を入力',
                  hintStyle: const TextStyle(color: Colors.white70), // ★ヒント文字を白に
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70), // ★枠線を白に
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Colors.white70),
                ),
            ),
            TextButton(
              onPressed: () async {
                if (newExerciseName.isNotEmpty && selectedBodyPart != null) {
                  try {
                    final trimmedName = newExerciseName.trim();
                    // DBに保存（既存の場合は既存IDを返す）
                    await DatabaseHelper.instance.insertExercise(
                      category: selectedBodyPart!.displayName,
                      name: trimmedName,
                    );
                    await _loadExercises();
                    if (!mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('保存失敗: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('部位と種目名を入力してください')),
                  );
                }
              },
              child: const Text(
                '追加',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExerciseForBodyPartDialog(BodyPart bodyPart) {
    String newExerciseName = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          '種目を追加',
          style: AppTextStyles.pageTitle,
        ),
        content: TextField(
          style: const TextStyle(color: Colors.white), // ★入力された文字を白に
          onChanged: (value) {
            newExerciseName = value;
          },
          decoration: InputDecoration(
            hintText: '種目名を入力',
              hintStyle: const TextStyle(color: Colors.white70), // ★ヒント文字を白に
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (newExerciseName.isNotEmpty) {
                try {
                  // 入力された名前の前後から空白を除去
                  final trimmedName = newExerciseName.trim();

                  // DBに保存（既存の場合は既存IDを返す）
                  await DatabaseHelper.instance.insertExercise(
                    category: bodyPart.displayName,
                    name: trimmedName,
                  );
                  // 保存に成功したらDBから最新状態を読み込む
                  await _loadExercises();
                  if (!mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('保存失敗: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('種目名を入力してください')),
                );
              }
            },
            child: const Text(
              '追加',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
