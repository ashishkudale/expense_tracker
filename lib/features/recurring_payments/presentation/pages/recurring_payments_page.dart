import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/di/di.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../onboarding/domain/repositories/user_profile_repository.dart';
import '../../../transactions/presentation/bloc/transactions_bloc.dart';
import '../../../transactions/presentation/bloc/transactions_event.dart';
import '../bloc/recurring_payments_bloc.dart';
import '../bloc/recurring_payments_event.dart';
import '../bloc/recurring_payments_state.dart';
import '../widgets/add_recurring_payment_bottom_sheet.dart';
import '../widgets/recurring_payment_item.dart';

class RecurringPaymentsPage extends StatefulWidget {
  const RecurringPaymentsPage({super.key});

  @override
  State<RecurringPaymentsPage> createState() => _RecurringPaymentsPageState();
}

class _RecurringPaymentsPageState extends State<RecurringPaymentsPage> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    context.read<RecurringPaymentsBloc>().add(RecurringPaymentsLoadRequested());
  }

  Future<void> _loadCategories() async {
    final result = await getIt<CategoryRepository>().getCategories();
    if (result.isSuccess && mounted) {
      setState(() {
        _categories = result.data ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Process Due Payments',
            onPressed: () {
              context.read<RecurringPaymentsBloc>().add(RecurringPaymentsProcessDueRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<RecurringPaymentsBloc, RecurringPaymentsState>(
        listener: (context, state) {
          if (state is RecurringPaymentsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is RecurringPaymentsProcessed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Processed ${state.processedCount} recurring payment(s)'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh transactions list
            context.read<TransactionsBloc>().add(TransactionsLoadRequested());
          }
        },
        builder: (context, state) {
          if (state is RecurringPaymentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecurringPaymentsLoaded ||
              state is RecurringPaymentsProcessing ||
              state is RecurringPaymentsProcessed) {
            final payments = state is RecurringPaymentsLoaded
                ? state.payments
                : state is RecurringPaymentsProcessing
                    ? state.payments
                    : (state as RecurringPaymentsProcessed).payments;

            if (payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No recurring payments yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add one',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return FutureBuilder<String>(
              future: _getCurrencySymbol(),
              builder: (context, snapshot) {
                final currencySymbol = snapshot.data ?? '\$';

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    final category = _categories.firstWhere(
                      (c) => c.id == payment.categoryId,
                      orElse: () => CategoryModel(
                        id: payment.categoryId,
                        name: 'Unknown',
                        type: CategoryType.spend,
                        createdAt: DateTime.now(),
                      ),
                    );

                    return RecurringPaymentItem(
                      payment: payment,
                      category: category,
                      currencySymbol: currencySymbol,
                      onToggle: (isActive) {
                        context.read<RecurringPaymentsBloc>().add(
                          RecurringPaymentToggleStatusRequested(payment.id, isActive),
                        );
                      },
                      onDelete: () {
                        _showDeleteDialog(context, payment.id);
                      },
                    );
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_categories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please add categories first'),
              ),
            );
            return;
          }

          final bloc = context.read<RecurringPaymentsBloc>();

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (bottomSheetContext) => Container(
              decoration: BoxDecoration(
                color: Theme.of(bottomSheetContext).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: BlocProvider.value(
                value: bloc,
                child: AddRecurringPaymentBottomSheet(
                  categories: _categories,
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String paymentId) {
    final unusedWarning = paymentId.toString(); // Unused variable - triggers warning
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Recurring Payment'),
        content: const Text(
          'Are you sure you want to delete this recurring payment? '
          'This will not delete past transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<RecurringPaymentsBloc>().add(
                RecurringPaymentDeleteRequested(paymentId),
              );
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
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
