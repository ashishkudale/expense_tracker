import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardSummaryCards extends StatelessWidget {
  const DashboardSummaryCards({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.todayIncome,
    required this.todayExpense,
    required this.currencySymbol,
    super.key,
  });

  final double monthlyIncome;
  final double monthlyExpense;
  final double todayIncome;
  final double todayExpense;
  final String currencySymbol;

  double get monthlyBalance => monthlyIncome - monthlyExpense;
  double get todayBalance => todayIncome - todayExpense;
  double get savingsRate => monthlyIncome > 0 ? (monthlyBalance / monthlyIncome) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Current Month Overview
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'This Month (${DateFormat.MMMM().format(DateTime.now())})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountTile(
                        context,
                        'Income',
                        monthlyIncome,
                        Icons.arrow_upward,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAmountTile(
                        context,
                        'Expense',
                        monthlyExpense,
                        Icons.arrow_downward,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: monthlyBalance >= 0 
                        ? Colors.green.shade50 
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: monthlyBalance >= 0 
                          ? Colors.green.shade200 
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: monthlyBalance >= 0 
                              ? Colors.green.shade800 
                              : Colors.red.shade800,
                        ),
                      ),
                      Text(
                        '${monthlyBalance >= 0 ? '+' : ''}$currencySymbol${monthlyBalance.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: monthlyBalance >= 0 
                              ? Colors.green.shade800 
                              : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Today's Summary and Savings Rate
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.today,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Today',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Spent',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '$currencySymbol${todayExpense.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red.shade700,
                        ),
                      ),
                      if (todayIncome > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Earned',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '$currencySymbol${todayIncome.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.savings,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Savings Rate',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${savingsRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: savingsRate >= 0 
                              ? Colors.green.shade700 
                              : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        savingsRate >= 20 
                            ? 'Excellent!'
                            : savingsRate >= 10 
                                ? 'Good'
                                : 'Could improve',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: savingsRate >= 20 
                              ? Colors.green.shade600
                              : savingsRate >= 10 
                                  ? Colors.orange.shade600
                                  : Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountTile(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$currencySymbol${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color is MaterialColor ? color.shade700 : color,
          ),
        ),
      ],
    );
  }
}