import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/report_entities.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final List<CategoryBreakdown> categoryBreakdowns;

  const CategoryBreakdownChart({
    required this.categoryBreakdowns,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final expenseBreakdowns = categoryBreakdowns
        .where((breakdown) => breakdown.type == TransactionType.spend)
        .toList();
    
    final incomeBreakdowns = categoryBreakdowns
        .where((breakdown) => breakdown.type == TransactionType.earn)
        .toList();

    return Column(
      children: [
        if (expenseBreakdowns.isNotEmpty) ...[
          _ChartSection(
            title: 'Expense Breakdown',
            breakdowns: expenseBreakdowns,
            color: Colors.red,
          ),
          if (incomeBreakdowns.isNotEmpty) const SizedBox(height: 32),
        ],
        if (incomeBreakdowns.isNotEmpty)
          _ChartSection(
            title: 'Income Breakdown',
            breakdowns: incomeBreakdowns,
            color: Colors.green,
          ),
      ],
    );
  }
}

class _ChartSection extends StatefulWidget {
  final String title;
  final List<CategoryBreakdown> breakdowns;
  final Color color;

  const _ChartSection({
    required this.title,
    required this.breakdowns,
    required this.color,
  });

  @override
  State<_ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<_ChartSection> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _generateSections(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _Legend(
                  breakdowns: widget.breakdowns,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generateSections() {
    return widget.breakdowns.asMap().entries.map((entry) {
      final index = entry.key;
      final breakdown = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      
      return PieChartSectionData(
        color: _getColorForIndex(index),
        value: breakdown.percentage,
        title: '${breakdown.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColorForIndex(int index) {
    final colors = widget.color == Colors.red
        ? [
            Colors.red.shade400,
            Colors.red.shade300,
            Colors.red.shade200,
            Colors.pink.shade300,
            Colors.pink.shade200,
            Colors.deepOrange.shade300,
          ]
        : [
            Colors.green.shade400,
            Colors.green.shade300,
            Colors.green.shade200,
            Colors.teal.shade300,
            Colors.teal.shade200,
            Colors.lightGreen.shade300,
          ];
    
    return colors[index % colors.length];
  }
}

class _Legend extends StatelessWidget {
  final List<CategoryBreakdown> breakdowns;
  final Color color;

  const _Legend({
    required this.breakdowns,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: breakdowns.asMap().entries.map((entry) {
                final index = entry.key;
                final breakdown = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getColorForIndex(index),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              breakdown.categoryName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${breakdown.transactionCount} transactions',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    final colors = color == Colors.red
        ? [
            Colors.red.shade400,
            Colors.red.shade300,
            Colors.red.shade200,
            Colors.pink.shade300,
            Colors.pink.shade200,
            Colors.deepOrange.shade300,
          ]
        : [
            Colors.green.shade400,
            Colors.green.shade300,
            Colors.green.shade200,
            Colors.teal.shade300,
            Colors.teal.shade200,
            Colors.lightGreen.shade300,
          ];
    
    return colors[index % colors.length];
  }
}