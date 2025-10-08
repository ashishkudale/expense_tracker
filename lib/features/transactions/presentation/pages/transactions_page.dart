import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/di.dart';
import '../../../../core/utils/csv_service.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_filtered_transactions.dart';
import '../../domain/usecases/get_period_totals.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import '../widgets/add_transaction_bottom_sheet.dart';
import '../widgets/edit_transaction_bottom_sheet.dart';
import '../widgets/transaction_item.dart';
import '../widgets/transactions_stats_header.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionsBloc(
        addTransaction: AddTransaction(getIt()),
        updateTransaction: UpdateTransaction(getIt()),
        deleteTransaction: DeleteTransaction(getIt()),
        getTransactions: GetTransactions(getIt()),
        getFilteredTransactions: GetFilteredTransactions(getIt()),
        getPeriodTotals: GetPeriodTotals(getIt()),
      )..add(const TransactionsLoadRequested()),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatefulWidget {
  const _TransactionsView();

  @override
  State<_TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<_TransactionsView> {
  final _searchController = TextEditingController();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final result = await getIt<CategoryRepository>().getCategories();
    if (result.isSuccess) {
      if (mounted) {
        setState(() {
          _categories = result.data!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: BlocConsumer<TransactionsBloc, TransactionsState>(
              listener: (context, state) {
                if (state is TransactionsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TransactionsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TransactionsEmpty) {
                  return _buildEmptyState(context, state);
                } else if (state is TransactionsLoaded || 
                          state is TransactionOperationInProgress) {
                  final transactions = state is TransactionsLoaded
                      ? state.transactions
                      : (state as TransactionOperationInProgress).transactions;
                  final isLoading = state is TransactionOperationInProgress;
                  final loadedState = state is TransactionsLoaded ? state : null;
                  
                  return Column(
                    children: [
                      if (loadedState?.todayTotals != null || loadedState?.monthTotals != null)
                        TransactionsStatsHeader(
                          todayTotals: loadedState?.todayTotals,
                          monthTotals: loadedState?.monthTotals,
                        ),
                      Expanded(
                        child: _buildTransactionsList(transactions, isLoading),
                      ),
                    ],
                  );
                } else if (state is TransactionsError) {
                  return _buildErrorState(state.message);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: 'Add new transaction',
        button: true,
        child: FloatingActionButton(
          onPressed: () => _showAddTransactionBottomSheet(context),
          tooltip: 'Add transaction',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search transactions',
                hintText: 'Search by note...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                context.read<TransactionsBloc>().add(
                  TransactionSearchChanged(query),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export') {
                await _exportTransactions();
              } else if (value == 'import') {
                await _importTransactions();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download, size: 20),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload, size: 20),
                    SizedBox(width: 8),
                    Text('Import CSV'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final currentTypeFilter = state is TransactionsLoaded 
            ? state.currentTypeFilter
            : state is TransactionsEmpty
                ? state.currentTypeFilter
                : null;
        
        final currentCategoryFilter = state is TransactionsLoaded 
            ? state.currentCategoryFilter
            : state is TransactionsEmpty
                ? state.currentCategoryFilter
                : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type filters
              Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: currentTypeFilter == null,
                    onSelected: (_) => _onTypeFilterChanged(null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_circle_outline, size: 16, color: Colors.red),
                        SizedBox(width: 4),
                        Text('Expenses'),
                      ],
                    ),
                    selected: currentTypeFilter == TransactionType.spend,
                    onSelected: (_) => _onTypeFilterChanged(TransactionType.spend),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text('Income'),
                      ],
                    ),
                    selected: currentTypeFilter == TransactionType.earn,
                    onSelected: (_) => _onTypeFilterChanged(TransactionType.earn),
                  ),
                ],
              ),
              // Category filters
              if (_categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Categories'),
                        selected: currentCategoryFilter == null,
                        onSelected: (_) => _onCategoryFilterChanged(null),
                      ),
                      const SizedBox(width: 8),
                      ..._categories.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: currentCategoryFilter == category.id,
                          onSelected: (_) => _onCategoryFilterChanged(category.id),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions, bool isLoading) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final category = _categories.where((c) => c.id == transaction.categoryId).firstOrNull;
            
            return TransactionItem(
              transaction: transaction,
              category: category,
              onDelete: () => _showDeleteDialog(context, transaction),
              onEdit: () => _showEditTransactionBottomSheet(context, transaction),
            );
          },
        ),
        if (isLoading)
          Container(
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, TransactionsEmpty state) {
    String message = 'No transactions yet';
    if (state.currentTypeFilter != null || state.currentCategoryFilter != null || 
        state.currentSearchQuery != null) {
      message = 'No transactions match your filters';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first transaction',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onTypeFilterChanged(TransactionType? type) {
    final state = context.read<TransactionsBloc>().state;
    final currentCategoryFilter = state is TransactionsLoaded
        ? state.currentCategoryFilter
        : state is TransactionsEmpty
            ? state.currentCategoryFilter
            : null;
    final currentSearchQuery = state is TransactionsLoaded
        ? state.currentSearchQuery
        : state is TransactionsEmpty
            ? state.currentSearchQuery
            : null;

    context.read<TransactionsBloc>().add(
      TransactionsFilterChanged(
        filterType: type,
        categoryId: currentCategoryFilter,
        searchQuery: currentSearchQuery,
      ),
    );
  }

  void _onCategoryFilterChanged(String? categoryId) {
    final state = context.read<TransactionsBloc>().state;
    final currentTypeFilter = state is TransactionsLoaded
        ? state.currentTypeFilter
        : state is TransactionsEmpty
            ? state.currentTypeFilter
            : null;
    final currentSearchQuery = state is TransactionsLoaded
        ? state.currentSearchQuery
        : state is TransactionsEmpty
            ? state.currentSearchQuery
            : null;

    context.read<TransactionsBloc>().add(
      TransactionsFilterChanged(
        filterType: currentTypeFilter,
        categoryId: categoryId,
        searchQuery: currentSearchQuery,
      ),
    );
  }

  Future<void> _showAddTransactionBottomSheet(BuildContext context) async {
    // Reload categories to ensure we have the latest ones
    await _loadCategories();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionsBloc>(),
        child: AddTransactionBottomSheet(categories: _categories),
      ),
    );
  }

  Future<void> _showEditTransactionBottomSheet(BuildContext context, Transaction transaction) async {
    // Reload categories to ensure we have the latest ones
    await _loadCategories();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionsBloc>(),
        child: EditTransactionBottomSheet(
          transaction: transaction,
          categories: _categories,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionsBloc>().add(
                TransactionDeleteRequested(transaction.id),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _exportTransactions() async {
    final state = context.read<TransactionsBloc>().state;
    if (state is TransactionsLoaded) {
      try {
        final csvService = CsvService();
        await csvService.shareTransactionsCsv(
          transactions: state.transactions,
          categories: _categories,
          startDate: DateTime.now().subtract(const Duration(days: 365)),
          endDate: DateTime.now(),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transactions exported successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to export: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  Future<void> _importTransactions() async {
    try {
      final csvService = CsvService();
      final csvData = await csvService.importTransactionsFromCsv();
      
      if (csvData == null) {
        return;
      }
      
      final transactions = csvService.parseImportedTransactions(
        csvData: csvData,
        categories: _categories,
      );
      
      if (transactions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid transactions found in CSV'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      int imported = 0;
      for (final transaction in transactions) {
        context.read<TransactionsBloc>().add(
          TransactionAddRequested(
            type: transaction.type,
            categoryId: transaction.categoryId,
            amount: transaction.amount,
            occurredOn: transaction.occurredOn,
            note: transaction.note,
          ),
        );
        imported++;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported $imported transactions successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}