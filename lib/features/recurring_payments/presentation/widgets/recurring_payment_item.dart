import 'package:flutter/material.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/recurring_payment.dart';

class RecurringPaymentItem extends StatelessWidget {
  const RecurringPaymentItem({
    required this.payment,
    required this.category,
    required this.currencySymbol,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final RecurringPayment payment;
  final Category category;
  final String currencySymbol;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: payment.type == TransactionType.spend
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  child: Icon(
                    payment.type == TransactionType.spend
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    color: payment.type == TransactionType.spend
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payment.type == TransactionType.spend ? '-' : '+'}$currencySymbol${payment.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: payment.type == TransactionType.spend
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: category.type == CategoryType.spend
                                  ? Colors.red.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: category.type == CategoryType.spend
                                    ? Colors.red.shade200
                                    : Colors.green.shade200,
                              ),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: category.type == CategoryType.spend
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.repeat,
                                  size: 12,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  payment.frequency.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: payment.isActive,
                  onChanged: onToggle,
                ),
              ],
            ),
            if (payment.note != null && payment.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                payment.note!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Next: ${_formatDate(payment.nextDueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                if (payment.endDate != null) ...[
                  Text(
                    'Until: ${_formatDate(payment.endDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: Colors.red.shade400,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
