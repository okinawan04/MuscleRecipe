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
  BodyPart? _selectedBodyPart; // グラフで選択された部位

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
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<Map<BodyPart, double>>(
              future: _getMaxWeightsByBodyPart(_selectedDate),
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
                    child: Text('この日付のトレーニングデータはありません'),
                  );
                }

                // 表示するデータをフィルタリング
                final Map<BodyPart, double> displayData;
                if (_selectedBodyPart == null) {
                  // すべてを表示
                  displayData = data;
                } else {
                  // 選択した部位のみ表示
                  displayData = data.containsKey(_selectedBodyPart)
                      ? {_selectedBodyPart!: data[_selectedBodyPart]!}
                      : {};
                }

                if (displayData.isEmpty) {
                  return const Center(
                    child: Text('選択した部位のデータはありません'),
                  );
                }

                // グラフデータを作成
                final List<FlSpot> spots = [];
                int index = 0;
                for (final weight in displayData.values) {
                  spots.add(FlSpot(index.toDouble(), weight));
                  index++;
                }

                // 最大値を取得してグラフの高さを決定
                final maxWeight =
                    displayData.values.reduce((a, b) => a > b ? a : b);
                final graphMaxY = (maxWeight * 1.2).ceilToDouble();

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
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 &&
                                        index < displayData.keys.length) {
                                      final bodyPart =
                                          displayData.keys.toList()[index];
                                      return Transform.rotate(
                                        angle: -0.3,
                                        child: Text(
                                          bodyPart.displayName,
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

  /// 指定日付の部位ごとの最大重量を取得
  Future<Map<BodyPart, double>> _getMaxWeightsByBodyPart(
      DateTime date) async {
    final records =
        await DatabaseHelper.instance.getTrainingRecordsByDate(date);

    final Map<BodyPart, double> maxWeights = {};

    for (final record in records) {
      final categoryName = record['category'] as String?;
      final weight = record['weight'] as double?;

      if (categoryName != null && weight != null) {
        // categoryName から BodyPart を取得
        try {
          final bodyPart = BodyPart.values.firstWhere(
            (bp) => bp.displayName == categoryName,
          );

          // 最大重量を更新
          if (!maxWeights.containsKey(bodyPart) ||
              maxWeights[bodyPart]! < weight) {
            maxWeights[bodyPart] = weight;
          }
        } catch (e) {
          // BodyPart に該当しない場合はスキップ
        }
      }
    }

    return maxWeights;
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
            final selectedDate = DateTime(year, month, day);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuListScreen(selectedDate: selectedDate),
              ),
            );
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
