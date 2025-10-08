import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.createdAt,
    super.archived,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      createdAt: entity.createdAt,
      archived: entity.archived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type == CategoryType.spend ? 'SPEND' : 'EARN',
      'created_at': createdAt.millisecondsSinceEpoch,
      'archived': archived ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: (map['type'] as String) == 'SPEND' 
          ? CategoryType.spend 
          : CategoryType.earn,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      archived: (map['archived'] ?? 0) == 1,
    );
  }
}