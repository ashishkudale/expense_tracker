import 'package:sqflite/sqflite.dart';
import '../../../../core/db/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final DatabaseProvider _databaseProvider;

  UserProfileRepositoryImpl(this._databaseProvider);

  @override
  Future<Result<UserProfile?>> getUserProfile() async {
    try {
      final db = await _databaseProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'user_profile',
        limit: 1,
      );

      if (maps.isEmpty) {
        return const Success(null);
      }

      final profile = UserProfileModel.fromMap(maps.first);
      return Success(profile);
    } catch (e) {
      return Failure('Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Future<Result<UserProfile>> saveUserProfile(UserProfile profile) async {
    try {
      final db = await _databaseProvider.database;
      final model = UserProfileModel.fromEntity(profile);
      
      await db.transaction((txn) async {
        await txn.delete('user_profile');
        await txn.insert(
          'user_profile',
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      return Success(profile);
    } catch (e) {
      return Failure('Failed to save user profile: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> deleteUserProfile() async {
    try {
      final db = await _databaseProvider.database;
      await db.delete('user_profile');
      return const Success(true);
    } catch (e) {
      return Failure('Failed to delete user profile: ${e.toString()}');
    }
  }
}