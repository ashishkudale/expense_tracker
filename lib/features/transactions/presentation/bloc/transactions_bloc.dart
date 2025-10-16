import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_filtered_transactions.dart';
import '../../domain/usecases/get_period_totals.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GetTransactions _getTransactions;
  final GetFilteredTransactions _getFilteredTransactions;
  final GetPeriodTotals _getPeriodTotals;

  Timer? _searchDebounceTimer;

  TransactionsBloc({
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    required GetTransactions getTransactions,
    required GetFilteredTransactions getFilteredTransactions,
    required GetPeriodTotals getPeriodTotals,
  })  : _addTransaction = addTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _getTransactions = getTransactions,
        _getFilteredTransactions = getFilteredTransactions,
        _getPeriodTotals = getPeriodTotals,
        super(const TransactionsInitial()) {
    on<TransactionsLoadRequested>(_onTransactionsLoadRequested);
    on<TransactionsFilterChanged>(_onTransactionsFilterChanged);
    on<TransactionSearchChanged>(_onTransactionSearchChanged);
    on<TransactionAddRequested>(_onTransactionAddRequested);
    on<TransactionUpdateRequested>(_onTransactionUpdateRequested);
    on<TransactionDeleteRequested>(_onTransactionDeleteRequested);
    on<TransactionStatsRequested>(_onTransactionStatsRequested);
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }

  Future<void> _onTransactionsLoadRequested(
    TransactionsLoadRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(const TransactionsLoading());
    await _loadTransactions(emit);
  }

  Future<void> _onTransactionsFilterChanged(
    TransactionsFilterChanged event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(const TransactionsLoading());

    final result = await _getFilteredTransactions(
      GetFilteredTransactionsParams(
        type: event.filterType,
        categoryId: event.categoryId,
        searchQuery: event.searchQuery,
      ),
    );

    await result.fold(
      onSuccess: (transactions) async {
        if (transactions.isEmpty) {
          emit(TransactionsEmpty(
            currentTypeFilter: event.filterType,
            currentCategoryFilter: event.categoryId,
            currentSearchQuery: event.searchQuery,
          ));
          // Request stats to load period totals even when empty
          add(const TransactionStatsRequested());
        } else {
          emit(TransactionsLoaded(
            transactions: transactions,
            currentTypeFilter: event.filterType,
            currentCategoryFilter: event.categoryId,
            currentSearchQuery: event.searchQuery,
          ));
          // Request stats to load period totals (today and this month)
          add(const TransactionStatsRequested());
        }
      },
      onFailure: (message) async {
        emit(TransactionsError(message));
      },
    );
  }

  void _onTransactionSearchChanged(
    TransactionSearchChanged event,
    Emitter<TransactionsState> emit,
  ) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      add(TransactionsFilterChanged(
        filterType: state is TransactionsLoaded
            ? (state as TransactionsLoaded).currentTypeFilter
            : state is TransactionsEmpty
                ? (state as TransactionsEmpty).currentTypeFilter
                : null,
        categoryId: state is TransactionsLoaded
            ? (state as TransactionsLoaded).currentCategoryFilter
            : state is TransactionsEmpty
                ? (state as TransactionsEmpty).currentCategoryFilter
                : null,
        searchQuery: event.query.trim().isEmpty ? null : event.query.trim(),
      ));
    });
  }

  Future<void> _onTransactionAddRequested(
    TransactionAddRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(TransactionOperationInProgress(
        transactions: currentState.transactions,
        currentTypeFilter: currentState.currentTypeFilter,
        currentCategoryFilter: currentState.currentCategoryFilter,
        currentSearchQuery: currentState.currentSearchQuery,
      ));
    }

    final result = await _addTransaction(
      AddTransactionParams(
        type: event.type,
        categoryId: event.categoryId,
        amount: event.amount,
        occurredOn: event.occurredOn,
        note: event.note,
      ),
    );

    await result.fold(
      onSuccess: (transaction) async {
        add(const TransactionsLoadRequested());
      },
      onFailure: (message) async {
        emit(TransactionsError(message));
      },
    );
  }

  Future<void> _onTransactionUpdateRequested(
    TransactionUpdateRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(TransactionOperationInProgress(
        transactions: currentState.transactions,
        currentTypeFilter: currentState.currentTypeFilter,
        currentCategoryFilter: currentState.currentCategoryFilter,
        currentSearchQuery: currentState.currentSearchQuery,
      ));
    }

    final result = await _updateTransaction(
      UpdateTransactionParams(
        id: event.id,
        type: event.type,
        categoryId: event.categoryId,
        amount: event.amount,
        occurredOn: event.occurredOn,
        createdAt: event.createdAt,
        note: event.note,
      ),
    );

    await result.fold(
      onSuccess: (transaction) async {
        add(const TransactionsLoadRequested());
      },
      onFailure: (message) async {
        emit(TransactionsError(message));
      },
    );
  }

  Future<void> _onTransactionDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(TransactionOperationInProgress(
        transactions: currentState.transactions,
        currentTypeFilter: currentState.currentTypeFilter,
        currentCategoryFilter: currentState.currentCategoryFilter,
        currentSearchQuery: currentState.currentSearchQuery,
      ));
    }

    final result = await _deleteTransaction(
      DeleteTransactionParams(transactionId: event.transactionId),
    );

    await result.fold(
      onSuccess: (deleted) async {
        if (deleted) {
          add(const TransactionsLoadRequested());
        } else {
          emit(const TransactionsError('Failed to delete transaction'));
        }
      },
      onFailure: (message) async {
        emit(TransactionsError(message));
      },
    );
  }

  Future<void> _onTransactionStatsRequested(
    TransactionStatsRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is! TransactionsLoaded && state is! TransactionsEmpty) return;

    // Get today's totals
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Get this month's totals
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    final todayResult = await _getPeriodTotals(
      GetPeriodTotalsParams(
        startDate: todayStart,
        endDate: todayEnd,
      ),
    );

    final monthResult = await _getPeriodTotals(
      GetPeriodTotalsParams(
        startDate: monthStart,
        endDate: monthEnd,
      ),
    );

    if (todayResult.isSuccess && monthResult.isSuccess) {
      if (state is TransactionsLoaded) {
        final currentState = state as TransactionsLoaded;
        emit(currentState.copyWith(
          todayTotals: todayResult.data,
          monthTotals: monthResult.data,
        ));
      } else if (state is TransactionsEmpty) {
        final currentState = state as TransactionsEmpty;
        emit(currentState.copyWith(
          todayTotals: todayResult.data,
          monthTotals: monthResult.data,
        ));
      }
    }
  }

  Future<void> _loadTransactions(Emitter<TransactionsState> emit) async {
    final result = await _getTransactions();

    await result.fold(
      onSuccess: (transactions) async {
        if (transactions.isEmpty) {
          emit(const TransactionsEmpty());
        } else {
          emit(TransactionsLoaded(transactions: transactions));
          add(const TransactionStatsRequested());
        }
      },
      onFailure: (message) async {
        emit(TransactionsError(message));
      },
    );
  }
}