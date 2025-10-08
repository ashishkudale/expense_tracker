import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Result<UserProfile?>> getUserProfile();
  Future<Result<UserProfile>> saveUserProfile(UserProfile profile);
  Future<Result<bool>> deleteUserProfile();
}