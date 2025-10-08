import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/report_entities.dart';

class MonthlyTrendsChart extends StatelessWidget {
  final List<MonthlyTrend> monthlyTrends;

  const MonthlyTrendsChart({
    required this.monthlyTrends,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyTrends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final trend = monthlyTrends[groupIndex];
                      final label = rodIndex == 0 ? 'Income' : 'Expense';
                      final value = rodIndex == 0 
                          ? trend.totalIncome 
                          : trend.totalExpense;
                      
                      return BarTooltipItem(
                        '$label\n\$${value.toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < monthlyTrends.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              monthlyTrends[index].month,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxValue() * 0.2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: _generateBarGroups(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Legend(),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return monthlyTrends.asMap().entries.map((entry) {
      final index = entry.key;
      final trend = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: trend.totalIncome,
            color: Colors.green.shade400,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: trend.totalExpense,
            color: Colors.red.shade400,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }

  double _getMaxValue() {
    double maxValue = 0;
    for (final trend in monthlyTrends) {
      maxValue = [maxValue, trend.totalIncome, trend.totalExpense]
          .reduce((a, b) => a > b ? a : b);
    }
    return maxValue > 0 ? maxValue : 1000;
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: Colors.green.shade400,
          label: 'Income',
        ),
        const SizedBox(width: 24),
        _LegendItem(
          color: Colors.red.shade400,
          label: 'Expenses',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}