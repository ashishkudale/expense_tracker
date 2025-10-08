import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/transactions/domain/entities/transaction.dart';
import '../../../../../lib/features/transactions/presentation/bloc/transactions_bloc.dart';
import '../../../../../lib/features/transactions/presentation/bloc/transactions_event.dart';
import '../../../../../lib/features/transactions/presentation/bloc/transactions_state.dart';

void main() {
  group('TransactionsBloc', () {
    test('TransactionType enum values', () {
      expect(TransactionType.spend.toString(), 'TransactionType.spend');
      expect(TransactionType.earn.toString(), 'TransactionType.earn');
    });

    test('TransactionsInitial state equality', () {
      expect(
        const TransactionsInitial(),
        equals(const TransactionsInitial()),
      );
    });

    test('TransactionsLoading state equality', () {
      expect(
        const TransactionsLoading(),
        equals(const TransactionsLoading()),
      );
    });

    test('TransactionsError state equality', () {
      expect(
        const TransactionsError('Error message'),
        equals(const TransactionsError('Error message')),
      );
    });

    test('TransactionsLoaded state equality', () {
      final now = DateTime.now();
      final transactions = [
        Transaction(
          id: '1',
          type: TransactionType.spend,
          categoryId: 'cat1',
          amount: 100.0,
          occurredOn: now,
          createdAt: now,
        ),
      ];
      
      final state1 = TransactionsLoaded(
        transactions: transactions,
        currentTypeFilter: null,
        currentCategoryFilter: null,
        currentSearchQuery: '',
      );
      
      final state2 = TransactionsLoaded(
        transactions: transactions,
        currentTypeFilter: null,
        currentCategoryFilter: null,
        currentSearchQuery: '',
      );
      
      expect(state1, equals(state2));
    });

    group('Events', () {
      test('TransactionsLoadRequested equality', () {
        expect(
          const TransactionsLoadRequested(),
          equals(const TransactionsLoadRequested()),
        );
      });

      test('TransactionsFilterChanged equality', () {
        expect(
          const TransactionsFilterChanged(
            filterType: TransactionType.spend,
            categoryId: 'cat1',
            searchQuery: 'query',
          ),
          equals(const TransactionsFilterChanged(
            filterType: TransactionType.spend,
            categoryId: 'cat1',
            searchQuery: 'query',
          )),
        );
      });

      test('TransactionSearchChanged equality', () {
        expect(
          const TransactionSearchChanged('query'),
          equals(const TransactionSearchChanged('query')),
        );
      });

      test('TransactionAddRequested equality', () {
        final now = DateTime.now();
        expect(
          TransactionAddRequested(
            type: TransactionType.spend,
            categoryId: 'cat1',
            amount: 100.0,
            occurredOn: now,
            note: 'test',
          ),
          equals(TransactionAddRequested(
            type: TransactionType.spend,
            categoryId: 'cat1',
            amount: 100.0,
            occurredOn: now,
            note: 'test',
          )),
        );
      });

      test('TransactionDeleteRequested equality', () {
        expect(
          const TransactionDeleteRequested('id1'),
          equals(const TransactionDeleteRequested('id1')),
        );
      });

      test('TransactionStatsRequested equality', () {
        expect(
          const TransactionStatsRequested(),
          equals(const TransactionStatsRequested()),
        );
      });
    });

    group('States', () {
      test('TransactionsEmpty state equality', () {
        expect(
          const TransactionsEmpty(
            currentTypeFilter: TransactionType.spend,
            currentCategoryFilter: 'cat1',
            currentSearchQuery: 'query',
          ),
          equals(const TransactionsEmpty(
            currentTypeFilter: TransactionType.spend,
            currentCategoryFilter: 'cat1',
            currentSearchQuery: 'query',
          )),
        );
      });

      test('TransactionOperationInProgress state equality', () {
        final now = DateTime.now();
        final transactions = [
          Transaction(
            id: '1',
            type: TransactionType.spend,
            categoryId: 'cat1',
            amount: 100.0,
            occurredOn: now,
            createdAt: now,
          ),
        ];

        expect(
          TransactionOperationInProgress(
            transactions: transactions,
            currentTypeFilter: TransactionType.spend,
            currentCategoryFilter: 'cat1',
            currentSearchQuery: 'query',
          ),
          equals(TransactionOperationInProgress(
            transactions: transactions,
            currentTypeFilter: TransactionType.spend,
            currentCategoryFilter: 'cat1',
            currentSearchQuery: 'query',
          )),
        );
      });

      test('TransactionsLoaded copyWith method', () {
        final now = DateTime.now();
        final transactions = [
          Transaction(
            id: '1',
            type: TransactionType.spend,
            categoryId: 'cat1',
            amount: 100.0,
            occurredOn: now,
            createdAt: now,
          ),
        ];

        final originalState = TransactionsLoaded(
          transactions: transactions,
          currentTypeFilter: null,
          currentCategoryFilter: null,
          currentSearchQuery: '',
        );

        final newTransactions = [
          Transaction(
            id: '2',
            type: TransactionType.earn,
            categoryId: 'cat2',
            amount: 200.0,
            occurredOn: now,
            createdAt: now,
          ),
        ];

        final copiedState = originalState.copyWith(
          transactions: newTransactions,
          currentTypeFilter: TransactionType.earn,
        );

        expect(copiedState.transactions, equals(newTransactions));
        expect(copiedState.currentTypeFilter, equals(TransactionType.earn));
        expect(copiedState.currentCategoryFilter, isNull);
        expect(copiedState.currentSearchQuery, isEmpty);
      });
    });

    group('Transaction Entity', () {
      test('Transaction creation and equality', () {
        final now = DateTime.now();
        final transaction1 = Transaction(
          id: '1',
          type: TransactionType.spend,
          categoryId: 'cat1',
          amount: 100.0,
          occurredOn: now,
          createdAt: now,
          note: 'Test transaction',
        );

        final transaction2 = Transaction(
          id: '1',
          type: TransactionType.spend,
          categoryId: 'cat1',
          amount: 100.0,
          occurredOn: now,
          createdAt: now,
          note: 'Test transaction',
        );

        expect(transaction1, equals(transaction2));
      });

      test('Transaction props include all fields', () {
        final now = DateTime.now();
        final transaction = Transaction(
          id: '1',
          type: TransactionType.spend,
          categoryId: 'cat1',
          amount: 100.0,
          occurredOn: now,
          createdAt: now,
          note: 'Test transaction',
        );

        expect(transaction.props, [
          '1',
          TransactionType.spend,
          'cat1',
          100.0,
          now,
          'Test transaction',
          now,
        ]);
      });

      test('Transaction without note', () {
        final now = DateTime.now();
        final transaction = Transaction(
          id: '1',
          type: TransactionType.earn,
          categoryId: 'cat1',
          amount: 500.0,
          occurredOn: now,
          createdAt: now,
        );

        expect(transaction.note, isNull);
        expect(transaction.type, TransactionType.earn);
        expect(transaction.amount, 500.0);
      });

      test('Transaction different types are not equal', () {
        final now = DateTime.now();
        final transaction1 = Transaction(
          id: '1',
          type: TransactionType.spend,
          categoryId: 'cat1',
          amount: 100.0,
          occurredOn: now,
          createdAt: now,
        );

        final transaction2 = Transaction(
          id: '1',
          type: TransactionType.earn,
          categoryId: 'cat1',
          amount: 100.0,
          occurredOn: now,
          createdAt: now,
        );

        expect(transaction1, isNot(equals(transaction2)));
      });
    });
  });
}