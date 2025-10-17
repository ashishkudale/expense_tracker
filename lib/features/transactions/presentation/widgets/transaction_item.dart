import 'package:flutter/material.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/di/di.dart';
import '../../../../core/utils/date_format_helper.dart';
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
      future: _getUserPreferences(),
      builder: (context, snapshot) {
        final currencySymbol = snapshot.data?['currency'] ?? '\$';
        final dateFormat = snapshot.data?['dateFormat'] ?? 'dd/MM/yyyy';

        final transactionTypeLabel = transaction.type == TransactionType.spend
            ? 'Expense'
            : 'Income';
        final amountLabel = '$currencySymbol${transaction.amount.toStringAsFixed(2)}';
        final dateLabel = DateFormatHelper.formatDateString(transaction.occurredOn, dateFormat);
        
        return Semantics(
          label: '$transactionTypeLabel of $amountLabel on $dateLabel',
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            title: Text(
              '${transaction.type == TransactionType.spend ? '-' : '+'}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.type == TransactionType.spend
                    ? Colors.red.shade700
                    : Colors.green.shade700,
                fontSize: 16,
              ),
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
                  dateLabel,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (category != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: category!.type == CategoryType.spend
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: category!.type == CategoryType.spend
                                ? Colors.red.shade200
                                : Colors.green.shade200,
                          ),
                        ),
                        child: Text(
                          category!.name,
                          style: TextStyle(
                            fontSize: 10,
                            color: category!.type == CategoryType.spend
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (category != null) const SizedBox(height: 2),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label: 'Edit transaction',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: onEdit,
                            color: Colors.blue.shade400,
                            tooltip: 'Edit transaction',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        Semantics(
                          label: 'Delete transaction',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: onDelete,
                            color: Colors.red.shade400,
                            tooltip: 'Delete transaction',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  Future<Map<String, String>> _getUserPreferences() async {
    try {
      final profileResult = await getIt<UserProfileRepository>().getUserProfile();
      if (profileResult.isSuccess && profileResult.data != null) {
        final currency = Currencies.getByCode(profileResult.data!.currencyCode);
        return {
          'currency': currency?.symbol ?? '\$',
          'dateFormat': profileResult.data!.dateFormat,
        };
      }
    } catch (e) {
      // Fallback to default
    }
    return {
      'currency': '\$',
      'dateFormat': 'dd/MM/yyyy',
    };
  }
}