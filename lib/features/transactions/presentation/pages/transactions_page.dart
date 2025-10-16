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
  bool _isSearching = false;

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

  int _getActiveFilterCount() {
    int count = 0;
    final state = context.read<TransactionsBloc>().state;

    if (state is TransactionsLoaded || state is TransactionsEmpty) {
      final typeFilter = state is TransactionsLoaded
          ? state.currentTypeFilter
          : (state as TransactionsEmpty).currentTypeFilter;
      final categoryFilter = state is TransactionsLoaded
          ? state.currentCategoryFilter
          : (state as TransactionsEmpty).currentCategoryFilter;

      if (typeFilter != null) count++;
      if (categoryFilter != null) count++;
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<TransactionsBloc, TransactionsState>(
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
            final showStats = state.todayTotals != null || state.monthTotals != null;

            if (showStats) {
              return CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: false,
                    floating: true,
                    delegate: _StatsHeaderDelegate(
                      todayTotals: state.todayTotals,
                      monthTotals: state.monthTotals,
                    ),
                  ),
                  SliverFillRemaining(
                    child: _buildEmptyState(context, state),
                  ),
                ],
              );
            } else {
              return _buildEmptyState(context, state);
            }
          } else if (state is TransactionsLoaded ||
                    state is TransactionOperationInProgress) {
            final transactions = state is TransactionsLoaded
                ? state.transactions
                : (state as TransactionOperationInProgress).transactions;
            final isLoading = state is TransactionOperationInProgress;
            final loadedState = state is TransactionsLoaded ? state : null;
            final showStats = loadedState?.todayTotals != null || loadedState?.monthTotals != null;

            if (showStats) {
              return CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: false,
                    floating: true,
                    delegate: _StatsHeaderDelegate(
                      todayTotals: loadedState?.todayTotals,
                      monthTotals: loadedState?.monthTotals,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final transaction = transactions[index];
                        final category = _categories
                            .where((c) => c.id == transaction.categoryId)
                            .firstOrNull;

                        return TransactionItem(
                          transaction: transaction,
                          category: category,
                          onDelete: () => _showDeleteDialog(context, transaction),
                          onEdit: () => _showEditTransactionBottomSheet(context, transaction),
                        );
                      },
                      childCount: transactions.length,
                    ),
                  ),
                  if (isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            } else {
              return _buildTransactionsList(transactions, isLoading);
            }
          } else if (state is TransactionsError) {
            return _buildErrorState(state.message);
          } else {
            return const SizedBox.shrink();
          }
        },
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by note...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: (query) {
                context.read<TransactionsBloc>().add(
                  TransactionSearchChanged(query),
                );
              },
            )
          : const Text('Transactions'),
      actions: [
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close search',
            onPressed: () {
              final bloc = context.read<TransactionsBloc>();
              final state = bloc.state;

              // Get current filters
              TransactionType? currentTypeFilter;
              String? currentCategoryFilter;

              if (state is TransactionsLoaded) {
                currentTypeFilter = state.currentTypeFilter;
                currentCategoryFilter = state.currentCategoryFilter;
              } else if (state is TransactionsEmpty) {
                currentTypeFilter = state.currentTypeFilter;
                currentCategoryFilter = state.currentCategoryFilter;
              }

              setState(() {
                _isSearching = false;
                _searchController.clear();
              });

              // Reapply filters without search query
              bloc.add(
                TransactionsFilterChanged(
                  filterType: currentTypeFilter,
                  categoryId: currentCategoryFilter,
                  searchQuery: null,
                ),
              );
            },
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, state) {
              final filterCount = _getActiveFilterCount();
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filter',
                    onPressed: _showFilterBottomSheet,
                  ),
                  if (filterCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$filterCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
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
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<TransactionsBloc>(),
        child: _FilterBottomSheet(
          categories: _categories,
          onApply: () => Navigator.pop(sheetContext),
        ),
      ),
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

class _StatsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final PeriodTotals? todayTotals;
  final PeriodTotals? monthTotals;

  _StatsHeaderDelegate({
    required this.todayTotals,
    required this.monthTotals,
  });

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => 180; // Approximate height of the stats header with padding

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double shrinkPercentage = (shrinkOffset / maxExtent).clamp(0.0, 1.0);
    final double opacity = 1.0 - shrinkPercentage;
    final double currentExtent = maxExtent - shrinkOffset;

    return SizedBox(
      height: currentExtent,
      child: Opacity(
        opacity: opacity,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: TransactionsStatsHeader(
            todayTotals: todayTotals,
            monthTotals: monthTotals,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StatsHeaderDelegate oldDelegate) {
    return todayTotals != oldDelegate.todayTotals ||
           monthTotals != oldDelegate.monthTotals;
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final List<Category> categories;
  final VoidCallback onApply;

  const _FilterBottomSheet({
    required this.categories,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  TransactionType? _selectedType;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final state = context.read<TransactionsBloc>().state;
    if (state is TransactionsLoaded) {
      _selectedType = state.currentTypeFilter;
      _selectedCategoryId = state.currentCategoryFilter;
    } else if (state is TransactionsEmpty) {
      _selectedType = state.currentTypeFilter;
      _selectedCategoryId = state.currentCategoryFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title and clear button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Transactions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      _selectedCategoryId = null;
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Transaction Type Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedType == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.remove_circle_outline, size: 16, color: Colors.red),
                          SizedBox(width: 4),
                          Text('Expenses'),
                        ],
                      ),
                      selected: _selectedType == TransactionType.spend,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = TransactionType.spend;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline, size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text('Income'),
                        ],
                      ),
                      selected: _selectedType == TransactionType.earn,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = TransactionType.earn;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category Section
          if (widget.categories.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All Categories'),
                        selected: _selectedCategoryId == null,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryId = null;
                          });
                        },
                      ),
                      ...widget.categories.map((category) => ChoiceChip(
                        label: Text(category.name),
                        selected: _selectedCategoryId == category.id,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                        },
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<TransactionsBloc>().add(
                    TransactionsFilterChanged(
                      filterType: _selectedType,
                      categoryId: _selectedCategoryId,
                      searchQuery: null,
                    ),
                  );
                  widget.onApply();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}