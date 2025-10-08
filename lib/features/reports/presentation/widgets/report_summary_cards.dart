import 'package:flutter/material.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/di/di.dart';
import '../../../onboarding/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/report_entities.dart';

class ReportSummaryCards extends StatelessWidget {
  final PeriodReport report;

  const ReportSummaryCards({
    required this.report,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getCurrencySymbol(),
      builder: (context, snapshot) {
        final currencySymbol = snapshot.data ?? '\$';
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Income',
                    amount: report.totalIncome,
                    currencySymbol: currencySymbol,
                    color: Colors.green,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Expenses',
                    amount: report.totalExpense,
                    currencySymbol: currencySymbol,
                    color: Colors.red,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Balance',
                    amount: report.balance,
                    currencySymbol: currencySymbol,
                    color: report.balance >= 0 ? Colors.blue : Colors.orange,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Savings Rate',
                    amount: report.savingsRate,
                    currencySymbol: '%',
                    isPercentage: true,
                    color: Colors.purple,
                    icon: Icons.savings,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TransactionCountCard(
              count: report.transactionCount,
              startDate: report.startDate,
              endDate: report.endDate,
            ),
          ],
        );
      },
    );
  }

  Future<String> _getCurrencySymbol() async {
    try {
      final profileResult = await getIt<UserProfileRepository>().getUserProfile();
      if (profileResult.isSuccess && profileResult.data != null) {
        final currency = Currencies.getByCode(profileResult.data!.currencyCode);
        return currency?.symbol ?? '\$';
      }
    } catch (e) {
      // Fallback to default
    }
    return '\$';
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currencySymbol;
  final Color color;
  final IconData icon;
  final bool isPercentage;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currencySymbol,
    required this.color,
    required this.icon,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPercentage 
                ? '${amount.toStringAsFixed(1)}$currencySymbol'
                : '$currencySymbol${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCountCard extends StatelessWidget {
  final int count;
  final DateTime startDate;
  final DateTime endDate;

  const _TransactionCountCard({
    required this.count,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final daysDiff = endDate.difference(startDate).inDays + 1;
    final avgPerDay = count > 0 ? count / daysDiff : 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$count total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (count > 0) ...[
                      Text(
                        ' • ${avgPerDay.toStringAsFixed(1)} per day',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}