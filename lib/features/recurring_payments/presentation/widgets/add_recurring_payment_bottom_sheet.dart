import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/di/di.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../onboarding/domain/repositories/user_profile_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/recurring_payment.dart';
import '../bloc/recurring_payments_bloc.dart';
import '../bloc/recurring_payments_event.dart';

class AddRecurringPaymentBottomSheet extends StatefulWidget {
  const AddRecurringPaymentBottomSheet({
    required this.categories,
    super.key,
  });

  final List<Category> categories;

  @override
  State<AddRecurringPaymentBottomSheet> createState() => _AddRecurringPaymentBottomSheetState();
}

class _AddRecurringPaymentBottomSheetState extends State<AddRecurringPaymentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _uuid = const Uuid();

  TransactionType _selectedType = TransactionType.spend;
  Category? _selectedCategory;
  RecurrenceFrequency _selectedFrequency = RecurrenceFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories
          .where((c) => c.type == CategoryType.spend)
          .firstOrNull ?? widget.categories.first;
    }
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
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                    'Add Recurring Payment',
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
                          // Frequency
                          DropdownButtonFormField<RecurrenceFrequency>(
                            value: _selectedFrequency,
                            decoration: const InputDecoration(
                              labelText: 'Frequency',
                              prefixIcon: Icon(Icons.repeat),
                            ),
                            items: RecurrenceFrequency.values.map((frequency) {
                              return DropdownMenuItem(
                                value: frequency,
                                child: Text(frequency.displayName),
                              );
                            }).toList(),
                            onChanged: (frequency) {
                              if (frequency != null) {
                                setState(() {
                                  _selectedFrequency = frequency;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Start Date
                          InkWell(
                            onTap: _selectStartDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _formatDate(_startDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // End Date (Optional)
                          InkWell(
                            onTap: _selectEndDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Date (Optional)',
                                prefixIcon: const Icon(Icons.event),
                                suffixIcon: _endDate != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _endDate = null;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              child: Text(
                                _endDate != null ? _formatDate(_endDate!) : 'No end date',
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
                          onPressed: _onAddRecurringPayment,
                          child: const Text('Add Recurring Payment'),
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
      _selectedCategory = availableCategories.first;
    } else {
      _selectedCategory = null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _onAddRecurringPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text.trim());

      final recurringPayment = RecurringPayment(
        id: _uuid.v4(),
        type: _selectedType,
        categoryId: _selectedCategory!.id,
        amount: amount,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        frequency: _selectedFrequency,
        startDate: _startDate,
        endDate: _endDate,
        lastProcessedDate: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
        createdAt: DateTime.now(),
      );

      context.read<RecurringPaymentsBloc>().add(
        RecurringPaymentAddRequested(recurringPayment),
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
