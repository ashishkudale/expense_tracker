import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/delete_category.dart';
import 'package:expense_tracker/core/utils/result.dart' as app_result;

class MockCategoryRepository implements CategoryRepository {
  bool shouldFail = false;
  bool categoryInUse = false;
  final List<Category> _categories = [];

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

  @override
  Future<app_result.Result<Category>> addCategory(Category category) async {
    _categories.add(category);
    return app_result.Success(category);
  }

  @override
  Future<app_result.Result<List<Category>>> getCategories() async {
    return app_result.Success(_categories);
  }

  @override
  Future<app_result.Result<List<Category>>> getCategoriesByType(CategoryType type) async {
    final filtered = _categories.where((cat) => cat.type == type).toList();
    return app_result.Success(filtered);
  }
}

void main() {
  group('DeleteCategory', () {
    late DeleteCategory usecase;
    late MockCategoryRepository mockRepository;

    setUp(() {
      mockRepository = MockCategoryRepository();
      usecase = DeleteCategory(mockRepository);
    });

    test('should delete category successfully when valid ID provided', () async {
      const categoryId = 'test-category-id';

      final result = await usecase(categoryId);

      expect(result.isSuccess, true);
      expect(result.data, true);
    });

    test('should fail when category ID is empty', () async {
      final result = await usecase('');

      expect(result.isFailure, true);
      expect(result.error, 'Category ID cannot be empty');
    });

    test('should fail when category ID is only whitespace', () async {
      final result = await usecase('   ');

      expect(result.isFailure, true);
      expect(result.error, 'Category ID cannot be empty');
    });

    test('should fail when category is in use by transactions', () async {
      mockRepository.categoryInUse = true;
      const categoryId = 'in-use-category-id';

      final result = await usecase(categoryId);

      expect(result.isFailure, true);
      expect(result.error, 'Cannot delete category that is being used by transactions');
    });

    test('should fail when repository fails', () async {
      mockRepository.shouldFail = true;
      const categoryId = 'test-category-id';

      final result = await usecase(categoryId);

      expect(result.isFailure, true);
      expect(result.error, 'Failed to delete category');
    });

    test('should trim whitespace from category ID', () async {
      const categoryId = '  test-category-id  ';

      final result = await usecase(categoryId);

      expect(result.isSuccess, true);
      expect(result.data, true);
    });
  });
}