import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories_by_type.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';
import '../bloc/categories_state.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/category_item.dart';
import '../widgets/delete_category_dialog.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesBloc(
        addCategory: AddCategory(getIt()),
        deleteCategory: DeleteCategory(getIt()),
        getCategoriesByType: GetCategoriesByType(getIt()),
        categoryRepository: getIt(),
      )..add(const CategoriesLoadRequested()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _FilterChips(),
          Expanded(
            child: BlocConsumer<CategoriesBloc, CategoriesState>(
              listener: (context, state) {
                if (state is CategoriesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoriesEmpty) {
                  return _buildEmptyState(state.currentFilter);
                } else if (state is CategoriesLoaded || 
                          state is CategoryOperationInProgress) {
                  final categories = state is CategoriesLoaded
                      ? state.categories
                      : (state as CategoryOperationInProgress).categories;
                  final isLoading = state is CategoryOperationInProgress;
                  
                  return _buildCategoriesList(categories, isLoading);
                } else if (state is CategoriesError) {
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
        label: 'Add new category',
        button: true,
        child: FloatingActionButton(
          onPressed: () => _showAddCategoryDialog(context),
          tooltip: 'Add category',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildEmptyState(CategoryType? filterType) {
    final typeText = filterType == null 
        ? 'categories' 
        : filterType == CategoryType.spend 
            ? 'spend categories' 
            : 'earn categories';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No $typeText yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to create your first category',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(List<Category> categories, bool isLoading) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryItem(
              category: category,
              onDelete: () => _showDeleteDialog(context, category),
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

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoriesBloc>(),
        child: const AddCategoryDialog(),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoriesBloc>(),
        child: DeleteCategoryDialog(category: category),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        final currentFilter = state is CategoriesLoaded 
            ? state.currentFilter
            : state is CategoriesEmpty
                ? state.currentFilter
                : null;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: currentFilter == null,
                onSelected: (_) => context.read<CategoriesBloc>().add(
                  const CategoriesFilterChanged(),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_circle_outline, size: 16),
                    SizedBox(width: 4),
                    Text('Spend'),
                  ],
                ),
                selected: currentFilter == CategoryType.spend,
                onSelected: (_) => context.read<CategoriesBloc>().add(
                  const CategoriesFilterChanged(filterType: CategoryType.spend),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, size: 16),
                    SizedBox(width: 4),
                    Text('Earn'),
                  ],
                ),
                selected: currentFilter == CategoryType.earn,
                onSelected: (_) => context.read<CategoriesBloc>().add(
                  const CategoriesFilterChanged(filterType: CategoryType.earn),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}