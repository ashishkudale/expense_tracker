import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/add_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/delete_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories_by_type.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/categories_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/categories_state.dart';
import 'package:expense_tracker/core/utils/result.dart' as app_result;

class MockCategoryRepository implements CategoryRepository {
  bool shouldFail = false;
  bool categoryInUse = false;
  final List<Category> _categories = [];

  @override
  Future<app_result.Result<List<Category>>> getCategories() async {
    if (shouldFail) {
      return const app_result.Failure('Failed to get categories');
    }
    return app_result.Success(List.from(_categories));
  }

  @override
  Future<app_result.Result<List<Category>>> getCategoriesByType(CategoryType type) async {
    if (shouldFail) {
      return const app_result.Failure('Failed to get categories by type');
    }
    final filtered = _categories.where((cat) => cat.type == type).toList();
    return app_result.Success(filtered);
  }

  @override
  Future<app_result.Result<Category>> addCategory(Category category) async {
    if (shouldFail) {
      return const app_result.Failure('Failed to add category');
    }
    _categories.add(category);
    return app_result.Success(category);
  }

  @override
  Future<app_result.Result<bool>> deleteCategory(String categoryId) async {
    if (shouldFail) {
      return const app_result.Failure('Failed to delete category');
    }
    if (categoryInUse) {
      return const app_result.Failure('Cannot delete category that is being used by transactions');
    }
    _categories.removeWhere((cat) => cat.id == categoryId);
    return const app_result.Success(true);
  }

  @override
  Future<app_result.Result<bool>> isCategoryInUse(String categoryId) async {
    return app_result.Success(categoryInUse);
  }

  void addTestCategory(Category category) {
    _categories.add(category);
  }
}

void main() {
  group('CategoriesBloc', () {
    late CategoriesBloc bloc;
    late MockCategoryRepository mockRepository;

    final testCategory = Category(
      id: 'test-id',
      name: 'Test Category',
      type: CategoryType.spend,
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockRepository = MockCategoryRepository();
      bloc = CategoriesBloc(
        addCategory: AddCategory(mockRepository),
        deleteCategory: DeleteCategory(mockRepository),
        getCategoriesByType: GetCategoriesByType(mockRepository),
        categoryRepository: mockRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is CategoriesInitial', () {
      expect(bloc.state, const CategoriesInitial());
    });

    group('CategoriesLoadRequested', () {
      test('emits [CategoriesLoading, CategoriesLoaded] when categories loaded successfully', () async {
        mockRepository.addTestCategory(testCategory);

        final states = <CategoriesState>[];
        bloc.stream.listen(states.add);

        bloc.add(const CategoriesLoadRequested());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states, [
          const CategoriesLoading(),
          CategoriesLoaded(categories: [testCategory]),
        ]);
      });

      test('emits [CategoriesLoading, CategoriesEmpty] when no categories found', () async {
        final states = <CategoriesState>[];
        bloc.stream.listen(states.add);

        bloc.add(const CategoriesLoadRequested());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states, [
          const CategoriesLoading(),
          const CategoriesEmpty(),
        ]);
      });

      test('emits [CategoriesLoading, CategoriesError] when loading fails', () async {
        mockRepository.shouldFail = true;

        final states = <CategoriesState>[];
        bloc.stream.listen(states.add);

        bloc.add(const CategoriesLoadRequested());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states, [
          const CategoriesLoading(),
          const CategoriesError('Failed to get categories'),
        ]);
      });

      test('filters categories by type when filterType provided', () async {
        final spendCategory = Category(
          id: 'spend-id',
          name: 'Food',
          type: CategoryType.spend,
          createdAt: DateTime.now(),
        );
        final earnCategory = Category(
          id: 'earn-id',
          name: 'Salary',
          type: CategoryType.earn,
          createdAt: DateTime.now(),
        );

        mockRepository.addTestCategory(spendCategory);
        mockRepository.addTestCategory(earnCategory);

        final states = <CategoriesState>[];
        bloc.stream.listen(states.add);

        bloc.add(const CategoriesLoadRequested(filterType: CategoryType.spend));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], const CategoriesLoading());
        final loadedState = states[1] as CategoriesLoaded;
        expect(loadedState.categories.length, 1);
        expect(loadedState.categories[0].type, CategoryType.spend);
        expect(loadedState.currentFilter, CategoryType.spend);
      });
    });

    group('CategoryAddRequested', () {
      test('adds category and reloads list successfully', () async {
        final states = <CategoriesState>[];
        bloc.stream.listen(states.add);

        // First load to get initial state
        bloc.add(const CategoriesLoadRequested());
        await Future.delayed(const Duration(milliseconds: 50));

        // Then add category
        bloc.add(const CategoryAddRequested(
          name: 'New Category',
          type: CategoryType.spend,
        ));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 4);
        expect(states[0], const CategoriesLoading());
        expect(states[1], const CategoriesEmpty());
        expect(states[2], const CategoriesLoading());
        expect(states[3], isA<CategoriesLoaded>());
        
        final finalState = states[3] as CategoriesLoaded;
        expect(finalState.categories.length, 1);
        expect(finalState.categories[0].name, 'New Category');
      });

      test('emits error when add fails', () async {
        mockRepository.shouldFail = true;

        final states = <CategoriesState>[];
        bloc.stream.listen(states.add);

        bloc.add(const CategoryAddRequested(
          name: 'New Category',
          type: CategoryType.spend,
        ));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.last, isA<CategoriesError>());
      });
    });

    group('CategoryDeleteRequested', () {
      test('deletes category and reloads list successfully', () async {
        mockRepository.addTestCategory(testCategory);

        final states = <CategoriesState>[];
        bloc.stream.listen(states.add);

        // First load categories
        bloc.add(const CategoriesLoadRequested());
        await Future.delayed(const Duration(milliseconds: 50));

        // Then delete category
        bloc.add(const CategoryDeleteRequested('test-id'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 5);
        expect(states[0], const CategoriesLoading());
        expect(states[1], isA<CategoriesLoaded>());
        expect(states[2], isA<CategoryOperationInProgress>());
        expect(states[3], const CategoriesLoading()); // Reload triggered by delete
        expect(states[4], const CategoriesEmpty()); // Empty because we deleted the only category
      });

      test('emits error when category is in use', () async {
        mockRepository.categoryInUse = true;
        mockRepository.addTestCategory(testCategory);

        final states = <CategoriesState>[];
        bloc.stream.listen(states.add);

        // First load to set up initial state
        bloc.add(const CategoriesLoadRequested());
        await Future.delayed(const Duration(milliseconds: 50));

        // Then try to delete
        bloc.add(const CategoryDeleteRequested('test-id'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.last, const CategoriesError('Cannot delete category that is being used by transactions'));
      });
    });

    group('CategoriesFilterChanged', () {
      test('triggers reload with new filter', () async {
        final states = <CategoriesState>[];
        bloc.stream.listen(states.add);

        bloc.add(const CategoriesFilterChanged(filterType: CategoryType.spend));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states, [
          const CategoriesLoading(),
          const CategoriesEmpty(currentFilter: CategoryType.spend),
        ]);
      });
    });
  });
}