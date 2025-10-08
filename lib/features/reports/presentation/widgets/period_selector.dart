import 'package:flutter/material.dart';
import '../../domain/entities/report_entities.dart';

class PeriodSelector extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final Function(ReportPeriod) onPeriodChanged;
  final Function(DateTime, DateTime) onCustomDateRangeSelected;

  const PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.onCustomDateRangeSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Period',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _PeriodChip(
                label: 'Week',
                period: ReportPeriod.week,
                selectedPeriod: selectedPeriod,
                onSelected: onPeriodChanged,
              ),
              _PeriodChip(
                label: 'Month',
                period: ReportPeriod.month,
                selectedPeriod: selectedPeriod,
                onSelected: onPeriodChanged,
              ),
              _PeriodChip(
                label: 'Year',
                period: ReportPeriod.year,
                selectedPeriod: selectedPeriod,
                onSelected: onPeriodChanged,
              ),
              _CustomRangeChip(
                selectedPeriod: selectedPeriod,
                onCustomDateRangeSelected: onCustomDateRangeSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final ReportPeriod period;
  final ReportPeriod selectedPeriod;
  final Function(ReportPeriod) onSelected;

  const _PeriodChip({
    required this.label,
    required this.period,
    required this.selectedPeriod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedPeriod == period;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSelected(period);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}

class _CustomRangeChip extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final Function(DateTime, DateTime) onCustomDateRangeSelected;

  const _CustomRangeChip({
    required this.selectedPeriod,
    required this.onCustomDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedPeriod == ReportPeriod.custom;
    
    return ActionChip(
      label: Text(isSelected ? 'Custom Range' : 'Custom'),
      avatar: Icon(
        Icons.date_range,
        size: 18,
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface,
      ),
      backgroundColor: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      onPressed: () async {
        final dateRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
        );
        
        if (dateRange != null) {
          onCustomDateRangeSelected(dateRange.start, dateRange.end);
        }
      },
    );
  }
}