import '../../../../core/utils/result.dart';
import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository _repository;

  DeleteCategory(this._repository);

  Future<Result<bool>> call(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      return const Failure('Category ID cannot be empty');
    }

    return await _repository.deleteCategory(categoryId);
  }
}