import 'package:flutter/material.dart';
import '../models/training_models.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'menu_list_screen.dart';

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
  final TextEditingController _restTimeController =
      TextEditingController(text: '60');
  final List<TextEditingController> _weightControllers = [];
  final List<TextEditingController> _repControllers = [];

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
    for (final set in sets) {
      _weightControllers.add(
        TextEditingController(text: set.weight > 0 ? set.weight.toString() : ''),
      );
      _repControllers.add(
        TextEditingController(text: set.reps > 0 ? set.reps.toString() : ''),
      );
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
                    onPressed: () {
                      // Save training menu
                      Navigator.pop(context);
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
              // Copy button
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
        ],
      ),
    );
  }
}
