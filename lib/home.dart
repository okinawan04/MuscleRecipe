import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showCalendar = true;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF3A3642),
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFF3A3642),
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                children: [
                  const Text(
                    'Muscle memory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tab Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCalendar = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _showCalendar
                                ? const Color(0xFF5DADE2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: _showCalendar
                                ? null
                                : Border.all(
                                    color: const Color(0xFF5DADE2),
                                    width: 1,
                                  ),
                          ),
                          child: Text(
                            'グラフ',
                            style: TextStyle(
                              color: _showCalendar
                                  ? Colors.white
                                  : const Color(0xFF5DADE2),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCalendar = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _showCalendar
                                ? const Color(0xFF5DADE2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: _showCalendar
                                ? null
                                : Border.all(
                                    color: const Color(0xFF5DADE2),
                                    width: 1,
                                  ),
                          ),
                          child: Text(
                            'カレンダー',
                            style: TextStyle(
                              color: _showCalendar
                                  ? Colors.white
                                  : const Color(0xFF5DADE2),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content Area
            Expanded(
              child: _showCalendar ? _buildCalendar() : _buildGraph(),
            ),
            // Buttons Area
            Container(
              color: const Color(0xFF3A3642),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // Add Menu Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5DADE2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'メニューを追加',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Training Plan Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5DADE2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'トレーニングプラン',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Navigation
            Container(
              color: const Color(0xFF3A3642),
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavIcon(Icons.home, 0),
                  const SizedBox(width: 24),
                  _buildNavIcon(Icons.history, 1),
                  const SizedBox(width: 24),
                  _buildNavIcon(Icons.shopping_cart, 2),
                  const SizedBox(width: 24),
                  _buildNavIcon(Icons.notifications, 3),
                  const SizedBox(width: 24),
                  _buildNavIcon(Icons.person, 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: index == 0 ? const Color(0xFFD946A6) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildGraph() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '食入量',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return const Text('1月', style: style);
                          case 3:
                            return const Text('14日', style: style);
                          case 6:
                            return const Text('28日', style: style);
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        return Text(
                          '${value.toInt()}',
                          style: style,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 20),
                      FlSpot(1, 40),
                      FlSpot(2, 35),
                      FlSpot(3, 50),
                      FlSpot(4, 70),
                      FlSpot(5, 90),
                      FlSpot(6, 100),
                    ],
                    isCurved: true,
                    color: const Color(0xFF5DADE2),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    DateTime now = DateTime.now();
    int daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;
    int firstDayOfMonth =
        DateTime(now.year, now.month, 1).weekday;

    return Column(
      children: [
        // Month/Year Header
        Container(
          color: const Color(0xFF5DADE2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {},
              ),
              Text(
                DateFormat('MMMM yyyy', 'ja_JP').format(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
        // Weekday Headers
        Container(
          color: const Color(0xFF5DADE2),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['日', '月', '火', '水', '木', '金', '土']
                .map(
                  (day) => Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        // Calendar Grid
        Expanded(
          child: Container(
            color: const Color(0xFF5DADE2),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: firstDayOfMonth + daysInMonth - 1,
              itemBuilder: (context, index) {
                if (index < firstDayOfMonth - 1) {
                  return Container();
                }

                int day = index - firstDayOfMonth + 2;

                bool isSelected = day == _selectedDate.day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = DateTime(now.year, now.month, day);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD946A6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
