import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/di/di.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../onboarding/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';

class EditTransactionBottomSheet extends StatefulWidget {
  const EditTransactionBottomSheet({
    required this.transaction,
    required this.categories,
    super.key,
  });

  final Transaction transaction;
  final List<Category> categories;

  @override
  State<EditTransactionBottomSheet> createState() => _EditTransactionBottomSheetState();
}

class _EditTransactionBottomSheetState extends State<EditTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _selectedType;
  late Category? _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toStringAsFixed(2));
    _noteController = TextEditingController(text: widget.transaction.note ?? '');
    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.occurredOn;

    // Find the category for this transaction
    _selectedCategory = widget.categories
        .where((c) => c.id == widget.transaction.categoryId)
        .firstOrNull;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'Edit Transaction',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Transaction Type
                          const Text(
                            'Transaction Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<TransactionType>(
                                  title: const Row(
                                    children: [
                                      Icon(Icons.remove_circle_outline, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Expense'),
                                    ],
                                  ),
                                  value: TransactionType.spend,
                                  groupValue: _selectedType,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedType = value;
                                        _updateCategoryForType();
                                      });
                                    }
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<TransactionType>(
                                  title: const Row(
                                    children: [
                                      Icon(Icons.add_circle_outline, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Income'),
                                    ],
                                  ),
                                  value: TransactionType.earn,
                                  groupValue: _selectedType,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedType = value;
                                        _updateCategoryForType();
                                      });
                                    }
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Category
                          DropdownButtonFormField<Category>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _getAvailableCategories().map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Amount
                          FutureBuilder<String>(
                            future: _getCurrencySymbol(),
                            builder: (context, snapshot) {
                              final currencySymbol = snapshot.data ?? '\$';
                              return TextFormField(
                                controller: _amountController,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  hintText: '0.00',
                                  prefixText: '$currencySymbol ',
                                  prefixIcon: const Icon(Icons.attach_money),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  final amount = double.tryParse(value.trim());
                                  if (amount == null || amount <= 0) {
                                    return 'Please enter a valid amount greater than 0';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Date
                          InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Note
                          TextFormField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: 'Note (Optional)',
                              hintText: 'Add a note...',
                              prefixIcon: Icon(Icons.note_outlined),
                            ),
                            maxLines: 3,
                            maxLength: 500,
                            validator: (value) {
                              if (value != null && value.trim().length > 500) {
                                return 'Note cannot be longer than 500 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onUpdateTransaction,
                          child: const Text('Update Transaction'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Category> _getAvailableCategories() {
    final targetCategoryType = _selectedType == TransactionType.spend
        ? CategoryType.spend
        : CategoryType.earn;
    return widget.categories.where((c) => c.type == targetCategoryType).toList();
  }

  void _updateCategoryForType() {
    final availableCategories = _getAvailableCategories();
    if (availableCategories.isNotEmpty) {
      // Try to keep the same category if it's compatible with the new type
      if (_selectedCategory != null &&
          availableCategories.any((c) => c.id == _selectedCategory!.id)) {
        // Keep current category
      } else {
        _selectedCategory = availableCategories.first;
      }
    } else {
      _selectedCategory = null;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat.yMd().format(date);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _onUpdateTransaction() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text.trim());

      context.read<TransactionsBloc>().add(
        TransactionUpdateRequested(
          id: widget.transaction.id,
          type: _selectedType,
          categoryId: _selectedCategory!.id,
          amount: amount,
          occurredOn: _selectedDate,
          createdAt: widget.transaction.createdAt,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        ),
      );

      Navigator.of(context).pop();
    }
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
