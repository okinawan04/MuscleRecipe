import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ウェルカムテキスト
              const Text(
                'ようこそ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // カレンダー
              _buildCalendar(),
              const SizedBox(height: 24),

              // 通知セクション
              const Text(
                '通知',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildNotificationCard(
                icon: Icons.inventory_2,
                title: '在庫確認',
                message: '◯◯の在庫が少なくなっています',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildNotificationCard(
                icon: Icons.fitness_center,
                title: 'トレーニング',
                message: '今日のトレーニングを記録しましょう',
                color: Colors.blue,
              ),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
              children: _buildCalendarDays(),
            ),
          ],
        ),
      ),
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
    for (String day in weekDays) {
      days.add(
        Center(
          child: Text(
            day,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
            style: const TextStyle(color: Colors.grey),
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

      days.add(
        Container(
          decoration: isToday
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                )
              : null,
          child: Center(
            child: Text(
              '$i',
              style: TextStyle(
                color: isToday ? Colors.white : Colors.black,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
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
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return days;
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
