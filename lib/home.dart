import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'models/training_models.dart';
import 'database_helper.dart';
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
  Set<int> _trainingDays = {};
  BodyPart? _selectedBodyPart = BodyPart.values.first; // グラフで選択された部位

  @override
  void initState() {
    super.initState();
    _loadTrainingDaysForDisplayedMonth();
  }

  Future<void> _loadTrainingDaysForDisplayedMonth() async {
    final startDate = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final endDate = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final records = await DatabaseHelper.instance.getTrainingRecordsByDateRange(startDate, endDate);

    final days = <int>{};
    for (final record in records) {
      final trainingDate = record['training_date'] as String?;
      if (trainingDate == null) continue;
      final dateString = trainingDate.split('T').first;
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final day = int.tryParse(parts[2]);
        if (day != null) {
          days.add(day);
        }
      }
    }

    setState(() {
      _trainingDays = days;
    });
  }

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
                          builder: (context) => MenuListScreen(selectedDate: _selectedDate),
                        ),
                      ).then((_) => _loadTrainingDaysForDisplayedMonth());
                    },
                  ),
                  const SizedBox(height: 12),
                  // Training Plan Button
                  CustomElevatedButton(
                    label: 'トレーニングプラン',
                    onPressed: () async {
                      await TrainingPlanModal.show(context);
                      await Future.delayed(const Duration(milliseconds: 300));
                      _loadTrainingDaysForDisplayedMonth();
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
          const SizedBox(height: 12),
          // 部位選択ボタン
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBodyPartButton(null, 'すべて'),
                const SizedBox(width: 8),
                ...BodyPart.values.map((bodyPart) {
                  return _buildBodyPartButton(bodyPart, bodyPart.displayName);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<Map<String, double>>(
              future: _getMaxWeightsByDateRange(_selectedDate, _selectedBodyPart),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('エラーが発生しました: ${snapshot.error}'),
                  );
                }

                final data = snapshot.data ?? {};

                if (data.isEmpty) {
                  return const Center(
                    child: Text('この期間のトレーニングデータはありません'),
                  );
                }

                final startDate = _selectedDate.subtract(const Duration(days: 6));
                final dateKeys = List.generate(7, (index) {
                  final date = startDate.add(Duration(days: index));
                  return date.toIso8601String().split('T')[0];
                });
                final dateLabels = List.generate(
                  7,
                  (index) => DateFormat('MM/dd', 'ja_JP')
                      .format(startDate.add(Duration(days: index))),
                );

                final spots = List<FlSpot>.generate(7, (index) {
                  final dateKey = dateKeys[index];
                  final weight = data[dateKey] ?? 0.0;
                  return FlSpot(index.toDouble(), weight);
                });

                final maxWeight = spots.map((spot) => spot.y).fold<double>(
                  0.0,
                  (previousValue, element) => max(previousValue, element),
                );
                final graphMaxY = max(20.0, (maxWeight * 1.2).ceilToDouble());

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedBodyPart == null
                            ? '全部位の最大重量'
                            : '${_selectedBodyPart!.displayName}の最大重量',
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 20,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: AppColors.gridLineColor
                                      .withValues(alpha: 0.2),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < dateLabels.length) {
                                      return Transform.rotate(
                                        angle: -0.4,
                                        child: Text(
                                          dateLabels[index],
                                          style:
                                              AppTextStyles.gridLabel.copyWith(
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 20,
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
                              show: true,
                              border: Border.all(
                                color: AppColors.gridLineColor.withValues(alpha: 0.3),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: AppColors.primaryColor,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                ),
                              ),
                            ],
                            minX: 0,
                            maxX: 6,
                            minY: 0,
                            maxY: graphMaxY,
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
    );
  }

  /// 部位選択ボタン
  Widget _buildBodyPartButton(BodyPart? bodyPart, String label) {
    final isSelected = (bodyPart == null && _selectedBodyPart == null) ||
        (bodyPart == _selectedBodyPart);

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedBodyPart = bodyPart;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.primaryColor
            : Colors.grey.withValues(alpha: 0.2),
        foregroundColor:
            isSelected ? Colors.white : AppColors.primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 指定期間の部位ごとの最大重量を取得
  Future<Map<String, double>> _getMaxWeightsByDateRange(
    DateTime endDate,
    BodyPart? selectedBodyPart,
  ) async {
    final startDate = endDate.subtract(const Duration(days: 6));
    final records = await DatabaseHelper.instance
        .getTrainingRecordsByDateRange(startDate, endDate);

    final Map<String, double> maxWeightsByDate = {};
    final selectedCategory = selectedBodyPart?.displayName;

    for (final record in records) {
      final categoryName = record['category'] as String?;
      final weight = (record['weight'] as num?)?.toDouble();
      final trainingDate = record['training_date'] as String?;

      if (categoryName == null || weight == null || trainingDate == null) {
        continue;
      }
      if (selectedCategory != null && categoryName != selectedCategory) {
        continue;
      }

      final dateKey = trainingDate.split(' ')[0];
      if (!maxWeightsByDate.containsKey(dateKey) ||
          maxWeightsByDate[dateKey]! < weight) {
        maxWeightsByDate[dateKey] = weight;
      }
    }

    return maxWeightsByDate;
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
                  _loadTrainingDaysForDisplayedMonth();
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
                  _loadTrainingDaysForDisplayedMonth();
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

        final now = DateTime.now();
        final isToday = day == now.day && month == now.month && year == now.year;
        final isSelected = day == _selectedDate.day && 
                          _selectedDate.month == month && 
                          _selectedDate.year == year;

        return GestureDetector(
          onTap: () {
            final selectedDate = DateTime(year, month, day);
            setState(() {
              _selectedDate = selectedDate;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuListScreen(selectedDate: selectedDate),
              ),
            ).then((_) => _loadTrainingDaysForDisplayedMonth());
          },
          child: Container(
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.accentColor
                  : Colors.transparent,
              border: isToday
                  ? Border.all(
                      color: AppColors.accentColor,
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: AppTextStyles.calendarDay,
                ),
                const SizedBox(height: 6),
                if (_trainingDays.contains(day))
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMonthYearPicker(BuildContext context) {
    int selectedYear = _displayedMonth.year;
    int selectedMonth = _displayedMonth.month;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '年',
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      dropdownColor: AppColors.backgroundColor,
                      value: selectedYear,
                      isExpanded: true,
                      items: List.generate(
                        11,
                        (index) {
                          final year = 2020 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(
                              '$year年',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          dialogSetState(() {
                            selectedYear = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // 月の選択
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '月',
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      dropdownColor: AppColors.backgroundColor,
                      value: selectedMonth,
                      isExpanded: true,
                      items: List.generate(
                        12,
                        (index) {
                          final month = index + 1;
                          return DropdownMenuItem(
                            value: month,
                            child: Text(
                              '$month月',
                              style: TextStyle(
                              color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          dialogSetState(() {
                            selectedMonth = value;
                          });
                        }
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
                      color: AppTextStyles.buttonText.color,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _displayedMonth = DateTime(selectedYear, selectedMonth, 1);
                    });
                    _loadTrainingDaysForDisplayedMonth();
                    Navigator.pop(context);
                  },
                  child: Text(
                    '決定',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppTextStyles.buttonText.color,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
