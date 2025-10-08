import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesByType {
  final CategoryRepository _repository;

  GetCategoriesByType(this._repository);

  Future<Result<List<Category>>> call(CategoryType type) async {
    return await _repository.getCategoriesByType(type);
  }
}