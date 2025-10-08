import 'package:uuid/uuid.dart';
import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class AddCategory {
  final CategoryRepository _repository;

  AddCategory(this._repository);

  Future<Result<Category>> call({
    required String name,
    required CategoryType type,
  }) async {
    if (name.trim().isEmpty) {
      return const Failure('Category name cannot be empty');
    }

    if (name.trim().length > 50) {
      return const Failure('Category name cannot be longer than 50 characters');
    }

    final category = Category(
      id: const Uuid().v4(),
      name: name.trim(),
      type: type,
      createdAt: DateTime.now(),
    );

    return await _repository.addCategory(category);
  }
}