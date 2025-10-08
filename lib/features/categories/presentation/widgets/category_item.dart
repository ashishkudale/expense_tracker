import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/category.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    required this.category,
    required this.onDelete,
    super.key,
  });

  final Category category;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final categoryTypeLabel = category.type == CategoryType.spend ? 'Expense' : 'Income';
    final createdDateLabel = DateFormat.yMd().format(category.createdAt);
    
    return Semantics(
      label: '${category.name}, $categoryTypeLabel category, created on $createdDateLabel',
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Semantics(
            label: '$categoryTypeLabel category',
            child: CircleAvatar(
              backgroundColor: category.type == CategoryType.spend 
                  ? Colors.red.shade100 
                  : Colors.green.shade100,
              child: Icon(
                category.type == CategoryType.spend 
                    ? Icons.remove_circle_outline 
                    : Icons.add_circle_outline,
                color: category.type == CategoryType.spend 
                    ? Colors.red.shade700 
                    : Colors.green.shade700,
              ),
            ),
          ),
          title: Text(
            category.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '$categoryTypeLabel • Created $createdDateLabel${category.archived ? ' • Archived' : ''}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          trailing: Semantics(
            label: 'Delete ${category.name} category',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: Colors.red.shade400,
              tooltip: 'Delete category',
            ),
          ),
        ),
      ),
    );
  }
}