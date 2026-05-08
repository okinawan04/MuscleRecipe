import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'widgets/custom_bottom_navigation_bar.dart';
import 'widgets/tab_button.dart';
import 'widgets/custom_elevated_button.dart';
import 'screens/menu_list_screen.dart';
import 'widgets/training_plan_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showCalendar = true;
  DateTime _selectedDate = DateTime.now();
  late DateTime _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.backgroundColor,
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.backgroundColor,
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: const Text(
                        'Muscle memory',
                        style: AppTextStyles.pageTitle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tab Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TabButton(
                        label: 'グラフ',
                        isSelected: !_showCalendar,
                        onTap: () {
                          setState(() {
                            _showCalendar = false;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      TabButton(
                        label: 'カレンダー',
                        isSelected: _showCalendar,
                        onTap: () {
                          setState(() {
                            _showCalendar = true;
                          });
                        },
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
              color: AppColors.backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // Add Menu Button
                  CustomElevatedButton(
                    label: 'メニューを追加',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MenuListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Training Plan Button
                  CustomElevatedButton(
                    label: 'トレーニングプラン',
                    onPressed: () {
                      TrainingPlanModal.show(context);
                    },
                  ),
                ],
              ),
            ),
            // Bottom Navigation
            CustomBottomNavigationBar(
              items: [
                NavItem(icon: Icons.home, index: 0),
                NavItem(icon: Icons.history, index: 1),
                NavItem(icon: Icons.shopping_cart, index: 2),
                NavItem(icon: Icons.notifications, index: 3),
                NavItem(icon: Icons.person, index: 4),
              ],
              selectedIndex: 0,
              onTap: (index) {
                // Handle navigation
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraph() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最大重量',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.gridLineColor.withValues(alpha: 0.2),
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
                            const style = AppTextStyles.gridLabel;
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
                            const style = AppTextStyles.gridLabel;
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
                          FlSpot(0, 30),
                          FlSpot(1, 40),
                          FlSpot(2, 60),
                          FlSpot(3, 50),
                          FlSpot(4, 80),
                          FlSpot(5, 90),
                          FlSpot(6, 100),
                        ],
                        isCurved: true,
                        color: AppColors.primaryColor,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        // Month/Year Header
        Container(
          color: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                    );
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  _showMonthYearPicker(context);
                },
                child: Text(
                  DateFormat('MMMM yyyy', 'ja_JP').format(_displayedMonth),
                  style: AppTextStyles.calendarHeader,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        // Weekday Headers
        Container(
          color: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['日', '月', '火', '水', '木', '金', '土']
                .map(
                  (day) => Text(
                    day,
                    style: AppTextStyles.calendarWeekday,
                  ),
                )
                .toList(),
          ),
        ),
        // Calendar Grid
        Expanded(
          child: Container(
            color: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildCalendarGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfWeek = DateTime(year, month, 1).weekday;
    
    // 日曜日が0になるようにする（flutter のデフォルトは月曜日が1）
    final firstWeekdayIndex = firstDayOfWeek == 7 ? 0 : firstDayOfWeek;
    
    final calendarDays = <int?>[];
    
    // 前月の空白を追加
    for (int i = 0; i < firstWeekdayIndex; i++) {
      calendarDays.add(null);
    }
    
    // 当月の日付を追加
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add(i);
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.95,
      ),
      itemCount: calendarDays.length,
      itemBuilder: (context, index) {
        final day = calendarDays[index];
        
        if (day == null) {
          return Container();
        }

        final isSelected = day == _selectedDate.day && 
                          _selectedDate.month == month && 
                          _selectedDate.year == year;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = DateTime(year, month, day);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: AppTextStyles.calendarDay,
            ),
          ),
        );
      },
    );
  }

  void _showMonthYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          '年月を選択',
          style: AppTextStyles.pageTitle,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 年の選択
              Text(
                '年: ${_displayedMonth.year}',
                style: AppTextStyles.buttonText,
              ),
              Slider(
                value: _displayedMonth.year.toDouble(),
                min: 2020,
                max: 2030,
                divisions: 10,
                onChanged: (value) {
                  // Sliderで年を選択
                },
              ),
              const SizedBox(height: 20),
              // 月の選択
              Text(
                '月: ${_displayedMonth.month}',
                style: AppTextStyles.buttonText,
              ),
              Slider(
                value: _displayedMonth.month.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                onChanged: (value) {
                  // Sliderで月を選択
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              '決定',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
