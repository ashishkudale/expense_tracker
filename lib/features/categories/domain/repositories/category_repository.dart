import '../../../../core/utils/result.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Result<List<Category>>> getCategories();
  Future<Result<List<Category>>> getCategoriesByType(CategoryType type);
  Future<Result<Category>> addCategory(Category category);
  Future<Result<bool>> deleteCategory(String categoryId);
  Future<Result<bool>> isCategoryInUse(String categoryId);
}