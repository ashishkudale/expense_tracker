import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_period_totals.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
}

class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final TransactionType? currentTypeFilter;
  final String? currentCategoryFilter;
  final String? currentSearchQuery;
  final PeriodTotals? todayTotals;
  final PeriodTotals? monthTotals;

  const TransactionsLoaded({
    required this.transactions,
    this.currentTypeFilter,
    this.currentCategoryFilter,
    this.currentSearchQuery,
    this.todayTotals,
    this.monthTotals,
  });

  @override
  List<Object?> get props => [
        transactions,
        currentTypeFilter,
        currentCategoryFilter,
        currentSearchQuery,
        todayTotals,
        monthTotals,
      ];

  TransactionsLoaded copyWith({
    List<Transaction>? transactions,
    TransactionType? currentTypeFilter,
    String? currentCategoryFilter,
    String? currentSearchQuery,
    PeriodTotals? todayTotals,
    PeriodTotals? monthTotals,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      currentTypeFilter: currentTypeFilter ?? this.currentTypeFilter,
      currentCategoryFilter: currentCategoryFilter ?? this.currentCategoryFilter,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      todayTotals: todayTotals ?? this.todayTotals,
      monthTotals: monthTotals ?? this.monthTotals,
    );
  }
}

class TransactionsEmpty extends TransactionsState {
  final TransactionType? currentTypeFilter;
  final String? currentCategoryFilter;
  final String? currentSearchQuery;
  final PeriodTotals? todayTotals;
  final PeriodTotals? monthTotals;

  const TransactionsEmpty({
    this.currentTypeFilter,
    this.currentCategoryFilter,
    this.currentSearchQuery,
    this.todayTotals,
    this.monthTotals,
  });

  @override
  List<Object?> get props => [
        currentTypeFilter,
        currentCategoryFilter,
        currentSearchQuery,
        todayTotals,
        monthTotals,
      ];

  TransactionsEmpty copyWith({
    TransactionType? currentTypeFilter,
    String? currentCategoryFilter,
    String? currentSearchQuery,
    PeriodTotals? todayTotals,
    PeriodTotals? monthTotals,
  }) {
    return TransactionsEmpty(
      currentTypeFilter: currentTypeFilter ?? this.currentTypeFilter,
      currentCategoryFilter: currentCategoryFilter ?? this.currentCategoryFilter,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      todayTotals: todayTotals ?? this.todayTotals,
      monthTotals: monthTotals ?? this.monthTotals,
    );
  }
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionOperationInProgress extends TransactionsState {
  final List<Transaction> transactions;
  final TransactionType? currentTypeFilter;
  final String? currentCategoryFilter;
  final String? currentSearchQuery;

  const TransactionOperationInProgress({
    required this.transactions,
    this.currentTypeFilter,
    this.currentCategoryFilter,
    this.currentSearchQuery,
  });

  @override
  List<Object?> get props => [
        transactions,
        currentTypeFilter,
        currentCategoryFilter,
        currentSearchQuery,
      ];
}