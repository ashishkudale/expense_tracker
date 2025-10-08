import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  CategoryType _selectedType = CategoryType.spend;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                if (value.trim().length > 50) {
                  return 'Name must be less than 50 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Category Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile<CategoryType>(
                  title: const Row(
                    children: [
                      Icon(Icons.remove_circle_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Expense (Spend)'),
                    ],
                  ),
                  value: CategoryType.spend,
                  groupValue: _selectedType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<CategoryType>(
                  title: const Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Income (Earn)'),
                    ],
                  ),
                  value: CategoryType.earn,
                  groupValue: _selectedType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onAddCategory,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _onAddCategory() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<CategoriesBloc>().add(
        CategoryAddRequested(
          name: _nameController.text.trim(),
          type: _selectedType,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}