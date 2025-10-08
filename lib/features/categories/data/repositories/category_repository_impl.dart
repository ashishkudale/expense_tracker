import 'package:sqflite/sqflite.dart';
import '../../../../core/db/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseProvider _databaseProvider;

  CategoryRepositoryImpl(this._databaseProvider);

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final db = await _databaseProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'categories',
        orderBy: 'created_at DESC',
      );

      final categories = maps.map(CategoryModel.fromMap).toList();
      return Success(categories);
    } catch (e) {
      return Failure('Failed to get categories: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Category>>> getCategoriesByType(CategoryType type) async {
    try {
      final db = await _databaseProvider.database;
      final typeString = type == CategoryType.spend ? 'SPEND' : 'EARN';
      
      final List<Map<String, dynamic>> maps = await db.query(
        'categories',
        where: 'type = ?',
        whereArgs: [typeString],
        orderBy: 'created_at DESC',
      );

      final categories = maps.map(CategoryModel.fromMap).toList();
      return Success(categories);
    } catch (e) {
      return Failure('Failed to get categories by type: ${e.toString()}');
    }
  }

  @override
  Future<Result<Category>> addCategory(Category category) async {
    try {
      final db = await _databaseProvider.database;
      final model = CategoryModel.fromEntity(category);
      
      await db.insert(
        'categories',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Success(category);
    } catch (e) {
      return Failure('Failed to add category: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> deleteCategory(String categoryId) async {
    try {
      final db = await _databaseProvider.database;
      
      // Check if category is in use by any transactions
      final isInUseResult = await isCategoryInUse(categoryId);
      if (isInUseResult.isFailure) {
        return isInUseResult;
      }
      
      if (isInUseResult.data == true) {
        return const Failure('Cannot delete category that is being used by transactions');
      }
      
      final deletedRows = await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [categoryId],
      );

      return Success(deletedRows > 0);
    } catch (e) {
      return Failure('Failed to delete category: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> isCategoryInUse(String categoryId) async {
    try {
      final db = await _databaseProvider.database;
      
      final List<Map<String, dynamic>> result = await db.query(
        'transactions',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        limit: 1,
      );

      return Success(result.isNotEmpty);
    } catch (e) {
      return Failure('Failed to check if category is in use: ${e.toString()}');
    }
  }
}