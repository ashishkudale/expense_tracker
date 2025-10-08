import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';

class DeleteCategoryDialog extends StatelessWidget {
  const DeleteCategoryDialog({
    required this.category,
    super.key,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to delete "${category.name}"?'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'This action cannot be undone. Categories in use by transactions cannot be deleted.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _onDeleteCategory(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  void _onDeleteCategory(BuildContext context) {
    context.read<CategoriesBloc>().add(
      CategoryDeleteRequested(category.id),
    );
    Navigator.of(context).pop();
  }
}