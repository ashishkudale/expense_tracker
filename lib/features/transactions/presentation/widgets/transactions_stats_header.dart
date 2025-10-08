import 'package:flutter/material.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/di/di.dart';
import '../../../onboarding/domain/repositories/user_profile_repository.dart';
import '../../domain/usecases/get_period_totals.dart';

class TransactionsStatsHeader extends StatelessWidget {
  const TransactionsStatsHeader({
    this.todayTotals,
    this.monthTotals,
    super.key,
  });

  final PeriodTotals? todayTotals;
  final PeriodTotals? monthTotals;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getCurrencySymbol(),
      builder: (context, snapshot) {
        final currencySymbol = snapshot.data ?? '\$';
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (todayTotals != null) ...[
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Today',
                    todayTotals!,
                    currencySymbol,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (monthTotals != null)
                Expanded(
                  child: _buildStatCard(
                    context,
                    'This Month',
                    monthTotals!,
                    currencySymbol,
                    Colors.purple,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    PeriodTotals totals,
    String currencySymbol,
    Color color,
  ) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earned',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '$currencySymbol${totals.totalEarned.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '$currencySymbol${totals.totalSpent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${totals.balance >= 0 ? '' : '-'}$currencySymbol${totals.balance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: totals.balance >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
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