import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsLoadRequested extends TransactionsEvent {
  const TransactionsLoadRequested();
}

class TransactionsFilterChanged extends TransactionsEvent {
  final TransactionType? filterType;
  final String? categoryId;
  final String? searchQuery;

  const TransactionsFilterChanged({
    this.filterType,
    this.categoryId,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [filterType, categoryId, searchQuery];
}

class TransactionSearchChanged extends TransactionsEvent {
  final String query;

  const TransactionSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class TransactionAddRequested extends TransactionsEvent {
  final TransactionType type;
  final String categoryId;
  final double amount;
  final DateTime occurredOn;
  final String? note;

  const TransactionAddRequested({
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.occurredOn,
    this.note,
  });

  @override
  List<Object?> get props => [type, categoryId, amount, occurredOn, note];
}

class TransactionUpdateRequested extends TransactionsEvent {
  final String id;
  final TransactionType type;
  final String categoryId;
  final double amount;
  final DateTime occurredOn;
  final String? note;
  final DateTime createdAt;

  const TransactionUpdateRequested({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.occurredOn,
    required this.createdAt,
    this.note,
  });

  @override
  List<Object?> get props => [id, type, categoryId, amount, occurredOn, note, createdAt];
}

class TransactionDeleteRequested extends TransactionsEvent {
  final String transactionId;

  const TransactionDeleteRequested(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class TransactionStatsRequested extends TransactionsEvent {
  const TransactionStatsRequested();
}