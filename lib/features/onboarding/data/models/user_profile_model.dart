import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@JsonSerializable()
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.currencyCode,
    required super.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      currencyCode: entity.currencyCode,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency_code': currencyCode,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      currencyCode: map['currency_code'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}