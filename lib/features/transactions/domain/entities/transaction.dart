import 'package:equatable/equatable.dart';

enum TransactionType { spend, earn }

class Transaction extends Equatable {
  final String id;
  final TransactionType type;
  final String categoryId;
  final double amount;
  final DateTime occurredOn;
  final String? note;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.occurredOn,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        categoryId,
        amount,
        occurredOn,
        note,
        createdAt,
      ];

  Transaction copyWith({
    String? id,
    TransactionType? type,
    String? categoryId,
    double? amount,
    DateTime? occurredOn,
    String? note,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      occurredOn: occurredOn ?? this.occurredOn,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Transaction(id: $id, type: $type, amount: $amount, categoryId: $categoryId)';
}