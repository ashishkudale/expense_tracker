import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/add_category.dart';
import 'package:expense_tracker/core/utils/result.dart' as app_result;

class MockCategoryRepository implements CategoryRepository {
  bool shouldFail = false;
  final List<Category> _categories = [];

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
    _categories.removeWhere((cat) => cat.id == categoryId);
    return const app_result.Success(true);
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

  @override
  Future<app_result.Result<bool>> isCategoryInUse(String categoryId) async {
    return const app_result.Success(false);
  }
}

void main() {
  group('AddCategory', () {
    late AddCategory usecase;
    late MockCategoryRepository mockRepository;

    setUp(() {
      mockRepository = MockCategoryRepository();
      usecase = AddCategory(mockRepository);
    });

    test('should add category successfully when valid name and type provided', () async {
      final result = await usecase(
        name: 'Food',
        type: CategoryType.spend,
      );

      expect(result.isSuccess, true);
      expect(result.data?.name, 'Food');
      expect(result.data?.type, CategoryType.spend);
    });

    test('should trim whitespace from category name', () async {
      final result = await usecase(
        name: '  Food  ',
        type: CategoryType.spend,
      );

      expect(result.isSuccess, true);
      expect(result.data?.name, 'Food');
    });

    test('should fail when name is empty', () async {
      final result = await usecase(
        name: '',
        type: CategoryType.spend,
      );

      expect(result.isFailure, true);
      expect(result.error, 'Category name cannot be empty');
    });

    test('should fail when name is only whitespace', () async {
      final result = await usecase(
        name: '   ',
        type: CategoryType.spend,
      );

      expect(result.isFailure, true);
      expect(result.error, 'Category name cannot be empty');
    });

    test('should fail when name is too long', () async {
      final result = await usecase(
        name: 'a' * 51, // 51 characters
        type: CategoryType.spend,
      );

      expect(result.isFailure, true);
      expect(result.error, 'Category name cannot be longer than 50 characters');
    });

    test('should fail when repository fails', () async {
      mockRepository.shouldFail = true;

      final result = await usecase(
        name: 'Food',
        type: CategoryType.spend,
      );

      expect(result.isFailure, true);
      expect(result.error, 'Failed to add category');
    });

    test('should create category with correct properties', () async {
      final result = await usecase(
        name: 'Salary',
        type: CategoryType.earn,
      );

      expect(result.isSuccess, true);
      expect(result.data?.name, 'Salary');
      expect(result.data?.type, CategoryType.earn);
      expect(result.data?.id, isNotEmpty);
      expect(result.data?.createdAt, isA<DateTime>());
    });
  });
}