import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/di/di.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../onboarding/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/transaction.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    required this.transaction,
    this.category,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  final Transaction transaction;
  final Category? category;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCurrencySymbol(),
      builder: (context, snapshot) {
        final currencySymbol = snapshot.data ?? '\$';
        
        final transactionTypeLabel = transaction.type == TransactionType.spend 
            ? 'Expense' 
            : 'Income';
        final amountLabel = '$currencySymbol${transaction.amount.toStringAsFixed(2)}';
        final dateLabel = DateFormat.yMd().add_jm().format(transaction.occurredOn);
        
        return Semantics(
          label: '$transactionTypeLabel of $amountLabel on $dateLabel',
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Semantics(
                label: transactionTypeLabel,
                child: CircleAvatar(
                  backgroundColor: transaction.type == TransactionType.spend 
                      ? Colors.red.shade100 
                      : Colors.green.shade100,
                  child: Icon(
                    transaction.type == TransactionType.spend 
                        ? Icons.remove_circle_outline 
                        : Icons.add_circle_outline,
                    color: transaction.type == TransactionType.spend 
                        ? Colors.red.shade700 
                        : Colors.green.shade700,
                  ),
                ),
              ),
            title: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '${transaction.type == TransactionType.spend ? '-' : '+'}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transaction.type == TransactionType.spend 
                          ? Colors.red.shade700 
                          : Colors.green.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (category != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: category!.type == CategoryType.spend
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: category!.type == CategoryType.spend
                              ? Colors.red.shade200
                              : Colors.green.shade200,
                        ),
                      ),
                      child: Text(
                        category!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: category!.type == CategoryType.spend
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  Text(
                    transaction.note!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                Text(
                  DateFormat.yMd().add_jm().format(transaction.occurredOn),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: 'Edit transaction',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    color: Colors.blue.shade400,
                    tooltip: 'Edit transaction',
                  ),
                ),
                Semantics(
                  label: 'Delete transaction',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Colors.red.shade400,
                    tooltip: 'Delete transaction',
                  ),
                ),
              ],
            ),
          ),
        ),
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