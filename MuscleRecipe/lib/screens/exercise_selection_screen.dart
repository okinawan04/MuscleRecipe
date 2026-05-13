import 'package:flutter/material.dart';
import '../models/training_models.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'menu_creation_screen.dart';
import '../database_helper.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({super.key});

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
      final exercises = allExercises
          .where((e) => e.bodyPart == bodyPart)
          .toList();
      // Sort by creation date (newest first)
      exercises.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
      onTap: () {
        // Navigate to MenuCreationScreen with the selected exercise
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuCreationScreen(
              exercise: exercise,
              date: DateTime.now(), // Pass the current date
            ),
          ),
        );
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
        child: Text(
          exercise.name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
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
                hint: const Text('部位を選択'),
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
                onChanged: (value) {
                  newExerciseName = value;
                },
                decoration: InputDecoration(
                  hintText: '種目名を入力',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                if (newExerciseName.isNotEmpty && selectedBodyPart != null) {
                  // 1. データベース保存を先に完了させる
                  await DatabaseHelper.instance.insertExercise(
                    category: selectedBodyPart!.displayName,
                    name: newExerciseName,
                  );
                await _loadExercises(); // DBから再読み込み
                 Navigator.pop(context);
                }
              },
              child: const Text('追加'),
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
          onChanged: (value) {
            newExerciseName = value;
          },
          decoration: InputDecoration(
            hintText: '種目名を入力',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (newExerciseName.isNotEmpty) {
                setState(() {
                  final newExercise = Exercise(
                    name: newExerciseName,
                    bodyPart: bodyPart,
                  );
                  allExercises.add(newExercise);
                  _groupExercises();
                });
                // データベースに保存
                DatabaseHelper.instance.insertExercise(
                  category: bodyPart.displayName,
                  name: newExerciseName,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}
