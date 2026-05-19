import 'package:flutter/material.dart';
import '../models/training_models.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../database_helper.dart';
import 'menu_list_screen.dart';
import 'dart:async'; // ★タイマーを使うために必要です

class MenuCreationScreen extends StatefulWidget {
  final Exercise exercise;
  final DateTime date;

  const MenuCreationScreen({
    super.key,
    required this.exercise,
    required this.date,
  });

  @override
  State<MenuCreationScreen> createState() => _MenuCreationScreenState();
}

class _MenuCreationScreenState extends State<MenuCreationScreen> {
  late List<TrainingSet> sets;
  int restTimeSeconds = 60;
  Timer? _timer;               // タイマーの状況を管理する変数
  int _currentRemaining = 0;   // カウントダウン中の残り秒数
  final TextEditingController _restTimeController =
      TextEditingController(text: '60');
  final List<TextEditingController> _weightControllers = [];
  final List<TextEditingController> _repControllers = [];
  final List<TextEditingController> _memoControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize with 4 sets
    sets = List.generate(
      4,
      (index) => TrainingSet(
        setNumber: index + 1,
        reps: 0,
        weight: 0.0,
      ),
    );
    _initializeControllers();
  }

  void _initializeControllers() {
    _weightControllers.clear();
    _repControllers.clear();
    _memoControllers.clear();
    for (final set in sets) {
      _weightControllers.add(
        TextEditingController(text: set.weight > 0 ? set.weight.toString() : ''),
      );
      _repControllers.add(
        TextEditingController(text: set.reps > 0 ? set.reps.toString() : ''),
      );
      _memoControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _restTimeController.dispose();
    for (final controller in _weightControllers) {
      controller.dispose();
    }
    for (final controller in _repControllers) {
      controller.dispose();
    }
    for (final controller in _memoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSet() {
    setState(() {
      final newSetNumber = sets.length + 1;
      sets.add(
        TrainingSet(
          setNumber: newSetNumber,
          reps: 0,
          weight: 0.0,
        ),
      );
      _weightControllers.add(TextEditingController());
      _repControllers.add(TextEditingController());
      _memoControllers.add(TextEditingController());
    });
  }

  void _copyPreviousWeight(int setIndex) {
    if (setIndex > 0) {
      final previousWeight = double.tryParse(
            _weightControllers[setIndex - 1].text,
          ) ??
          0.0;
      _weightControllers[setIndex].text = previousWeight.toString();
      setState(() {
        sets[setIndex] = sets[setIndex].copyWith(weight: previousWeight);
      });
    }
  }

  void _copyPreviousReps(int setIndex) {
    if (setIndex > 0) {
      final previousReps = _repControllers[setIndex - 1].text;
      _repControllers[setIndex].text = previousReps;
      setState(() {
        final reps = int.tryParse(previousReps) ?? 0;
        sets[setIndex] = sets[setIndex].copyWith(reps: reps);
      });
    }
  }

  void _copyPreviousMemo(int setIndex) {
    if (setIndex > 0) {
      final previousMemo = _memoControllers[setIndex - 1].text;
      _memoControllers[setIndex].text = previousMemo;
    }
  }

  void _updateRestTime(String value) {
    final time = int.tryParse(value);
    if (time != null) {
      setState(() {
        restTimeSeconds = time;
      });
    }
  }

  void _showRestTimeDialog() {
    final controller = TextEditingController(text: restTimeSeconds.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'レストタイムを設定',
          style: AppTextStyles.pageTitle,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '秒数を入力',
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
              _updateRestTime(controller.text);
              Navigator.pop(context);
            },
            child: const Text('設定'),
          ),
          // ★ 新しく追加した「スタート」ボタン
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor, // アプリのメインカラー（オレンジ系など）
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            // 1. まず入力された秒数でレストタイムを更新・確定させる
            _updateRestTime(controller.text);
            
            // 2. ダイアログを閉じる
            Navigator.pop(context);
            
            // 3. タイマーカウントダウンを開始するメソッドを呼び出す
            // ※既存のプロジェクトにタイマー開始メソッド（例: _startTimer() など）があればそれを指定してください
            _startTimer(); 
          },
          child: const Text(
            'スタート',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _currentRemaining = restTimeSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentRemaining > 0) {
        setState(() {
          _currentRemaining--;
        });
        print('残り時間: $_currentRemaining秒');
      } else {
        timer.cancel();
        _showTimerFinishedDialog();
      }
    });
  }

  void _showTimerFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('終了', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.backgroundColor,
        content: const Text('レストタイムが終了しました！', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          child: Column(
            children: [
              // Header
              Container(
                color: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Pass the updated data back to MenuListScreen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MenuListScreen(),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Text(
                      widget.exercise.name,
                      style: AppTextStyles.calendarHeader,
                    ),
                    GestureDetector(
                      onTap: _showRestTimeDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: AppColors.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$restTimeSeconds',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Set management
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sets.length + 1,
                  itemBuilder: (context, index) {
                    if (index == sets.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: FloatingActionButton.extended(
                            onPressed: _addSet,
                            backgroundColor: AppColors.primaryColor,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'セットを追加',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return _buildSetRow(index);
                  },
                ),
              ),
              // Save button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Save training menu to database
                      await _saveTrainingRecords();
                      if (mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetRow(int setIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set ${setIndex + 1}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Copy button for weight
              GestureDetector(
                onTap: () => _copyPreviousWeight(setIndex),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: AppColors.primaryColor,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Weight input
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _weightControllers[setIndex],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    final weight = double.tryParse(value) ?? 0.0;
                    sets[setIndex] =
                        sets[setIndex].copyWith(weight: weight);
                  },
                  decoration: InputDecoration(
                    hintText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('kg', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              // Copy button for reps
              GestureDetector(
                onTap: () => _copyPreviousReps(setIndex),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: AppColors.primaryColor,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Reps input
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _repControllers[setIndex],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final reps = int.tryParse(value) ?? 0;
                    sets[setIndex] = sets[setIndex].copyWith(reps: reps);
                  },
                  decoration: InputDecoration(
                    hintText: '回',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('回', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          // Memo section with copy button
          Row(
            children: [
              // Copy button for memo
              GestureDetector(
                onTap: () => _copyPreviousMemo(setIndex),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: AppColors.primaryColor,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Memo input
              Expanded(
                child: TextField(
                  controller: _memoControllers[setIndex],
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'メモ（オプション）',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveTrainingRecords() async {
    try {
      final db = DatabaseHelper.instance;
      final dateString = widget.date.toIso8601String();

      // 1. 種目マスター(training_menus)に登録。
    // ここで DatabaseHelper 側が「同じ名前なら既存IDを返す」ロジックなら、
    // 種目マスターに同じ名前が溢れることはありません。
    final menuId = await db.insertExercise(
      category: widget.exercise.bodyPart.displayName,
      name: widget.exercise.name,
    );

    // 2. セットごとの記録を保存
    // 日付、重量、回数が同じでも「別のID」として保存されるようにします
    for (int i = 0; i < sets.length; i++) {
      final weight = double.tryParse(_weightControllers[i].text) ?? 0.0;
      final reps = int.tryParse(_repControllers[i].text) ?? 0;
      final memo = _memoControllers[i].text.isEmpty ? null : _memoControllers[i].text;

      // 日付(dateString)が含まれているため、別の日なら別のデータとして保存されます
      await db.insertTrainingRecord(
        menuId: menuId,
        trainingDate: dateString, 
        setNumber: i + 1, // i + 1 でセット数を確実にする
        weight: weight,
        reps: reps,
        restSeconds: restTimeSeconds,
        memo: memo,
      );
    }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e')),
      );
    }
  }
}
