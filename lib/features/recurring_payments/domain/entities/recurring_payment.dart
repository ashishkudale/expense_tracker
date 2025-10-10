import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction.dart';

enum RecurrenceFrequency {
  daily('Daily', 1),
  weekly('Weekly', 7),
  monthly('Monthly', 30),
  quarterly('Quarterly', 90),
  yearly('Yearly', 365);

  final String displayName;
  final int approximateDays;

  const RecurrenceFrequency(this.displayName, this.approximateDays);

  static RecurrenceFrequency fromString(String value) {
    return RecurrenceFrequency.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RecurrenceFrequency.monthly,
    );
  }
}

class RecurringPayment extends Equatable {
  final String id;
  final TransactionType type;
  final String categoryId;
  final double amount;
  final String? note;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime lastProcessedDate;
  final bool isActive;
  final DateTime createdAt;

  const RecurringPayment({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    this.note,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.lastProcessedDate,
    required this.isActive,
    required this.createdAt,
  });

  DateTime get nextDueDate {
    DateTime next = lastProcessedDate;
    switch (frequency) {
      case RecurrenceFrequency.daily:
        next = lastProcessedDate.add(const Duration(days: 1));
        break;
      case RecurrenceFrequency.weekly:
        next = lastProcessedDate.add(const Duration(days: 7));
        break;
      case RecurrenceFrequency.monthly:
        next = DateTime(
          lastProcessedDate.year,
          lastProcessedDate.month + 1,
          lastProcessedDate.day,
        );
        break;
      case RecurrenceFrequency.quarterly:
        next = DateTime(
          lastProcessedDate.year,
          lastProcessedDate.month + 3,
          lastProcessedDate.day,
        );
        break;
      case RecurrenceFrequency.yearly:
        next = DateTime(
          lastProcessedDate.year + 1,
          lastProcessedDate.month,
          lastProcessedDate.day,
        );
        break;
    }
    return next;
  }

  bool get shouldProcess {
    if (!isActive) return false;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return false;
    return DateTime.now().isAfter(nextDueDate) ||
           DateTime.now().isAtSameMomentAs(nextDueDate);
  }

  @override
  List<Object?> get props => [
        id,
        type,
        categoryId,
        amount,
        note,
        frequency,
        startDate,
        endDate,
        lastProcessedDate,
        isActive,
        createdAt,
      ];
}
