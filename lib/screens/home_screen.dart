import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<String> _recipeOptions = [
    '鶏の照り焼き',
    'サーモンサラダ',
    'プロテインパンケーキ',
    'ほうれん草のチーズ炒め',
  ];

  final Map<String, List<Map<String, String>>> _diaryEntries = {
    '2026-05-12': [
      {
        'recipe': '鶏の照り焼き',
        'note': '家族と一緒に作った。味付けがちょうど良かった。',
      },
    ],
    '2026-05-14': [
      {
        'recipe': 'サーモンサラダ',
        'note': 'さっぱりしてトレーニング後にぴったり。',
      },
      {
        'recipe': 'プロテインパンケーキ',
        'note': '朝食に栄養満点。',
      },
    ],
  };

  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.inventory_2,
      'title': '在庫確認',
      'message': '◯◯の在庫が少なくなっています',
      'color': Colors.orange,
    },
    {
      'icon': Icons.fitness_center,
      'title': 'トレーニング',
      'message': '今日のトレーニングを記録しましょう',
      'color': Colors.blue,
    },
    // 追加の通知例
    {
      'icon': Icons.inventory_2,
      'title': '在庫確認',
      'message': '別の在庫が少なくなっています',
      'color': Colors.orange,
    },
  ];

  Map<String, List<Map<String, dynamic>>> _groupNotifications() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final notification in _notifications) {
      final title = notification['title'] as String;
      if (!grouped.containsKey(title)) {
        grouped[title] = [];
      }
      grouped[title]!.add(notification);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF4FC3F7)
            : const Color(0xFFFFB300),
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // カレンダー
              _buildCalendar(),
              const SizedBox(height: 24),

              // 通知セクション
              const Text(
                '通知',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._buildNotificationCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  '${_selectedDate.year}年${_selectedDate.month}月',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.9,
              children: _buildCalendarDays(),
            ),
            _buildDiarySection(),
          ],
        ),
      ),
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<Map<String, String>> _entriesForDate(DateTime date) =>
      _diaryEntries[_dateKey(date)] ?? [];

  bool _hasDiaryOn(DateTime date) => _diaryEntries.containsKey(_dateKey(date));

  Future<void> _showAddDiaryDialog(BuildContext context) async {
    String selectedRecipe = _recipeOptions.first;
    final TextEditingController diaryTextController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('日記を追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedRecipe,
              decoration: const InputDecoration(labelText: 'レシピ'),
              items: _recipeOptions
                  .map(
                    (recipe) => DropdownMenuItem(
                      value: recipe,
                      child: Text(recipe),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedRecipe = value;
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: diaryTextController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'メモ',
                hintText: '今日作った料理や感想を記録しましょう',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final note = diaryTextController.text.trim();
              if (note.isEmpty) {
                return;
              }
              final key = _dateKey(_selectedDate);
              if (!_diaryEntries.containsKey(key)) {
                _diaryEntries[key] = [];
              }
              _diaryEntries[key]!.add(
                {
                  'recipe': selectedRecipe,
                  'note': note,
                },
              );
              setState(() {});
              Navigator.of(context).pop(true);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    diaryTextController.dispose();
    if (result == true) {
      setState(() {});
    }
  }

  Widget _buildDiarySection() {
    final entries = _entriesForDate(_selectedDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日 の日記',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () => _showAddDiaryDialog(context),
              child: const Text('日記追加'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Text(
            'この日の記録はありません。',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey[700],
            ),
          )
        else
          Column(
            children: entries
                .map(
                  (entry) => Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry['recipe'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry['note'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  List<Widget> _buildCalendarDays() {
    final List<String> weekDays = ['月', '火', '水', '木', '金', '土', '日'];
    final now = DateTime.now();
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final previousMonth = DateTime(_selectedDate.year, _selectedDate.month, 0);

    final daysInWeek = 7;
    final firstWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;
    final daysInPreviousMonth = previousMonth.day;

    final List<Widget> days = [];

    // 曜日ヘッダー
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    for (String day in weekDays) {
      days.add(
        Center(
          child: Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
    }

    // 前月の日付
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(
        Center(
          child: Text(
            '${daysInPreviousMonth - i + 1}',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey,
            ),
          ),
        ),
      );
    }

    // 当月の日付
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, i);
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      final isSelected = date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final hasDiary = _hasDiaryOn(date);

      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: isSelected
                      ? BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        )
                      : null,
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    '$i',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isToday
                              ? Theme.of(context).colorScheme.primary
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)),
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (hasDiary)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // 翌月の日付
    final remainingDays =
        (daysInWeek - (days.length % daysInWeek)) % daysInWeek;
    for (int i = 1; i <= remainingDays; i++) {
      days.add(
        Center(
          child: Text(
            '$i',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey,
            ),
          ),
        ),
      );
    }

    return days;
  }

  List<Widget> _buildNotificationCards() {
    final grouped = _groupNotifications();
    final List<Widget> cards = [];
    for (final entry in grouped.entries) {
      final title = entry.key;
      final list = entry.value;
      final icon = list[0]['icon'] as IconData;
      final color = list[0]['color'] as Color;
      final message = list.length == 1 ? list[0]['message'] as String : null;
      cards.add(
        _buildNotificationCard(
          icon: icon,
          title: title,
          count: list.length,
          color: color,
          message: message,
        ),
      );
      cards.add(const SizedBox(height: 12));
    }
    if (cards.isNotEmpty) {
      cards.removeLast(); // 最後のSizedBoxを削除
    }
    return cards;
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    String? message,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12.0),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count == 1 ? title : '$title: ${count}件の通知',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (count == 1 && message != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
