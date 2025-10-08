import 'package:equatable/equatable.dart';

enum CategoryType { spend, earn }

class Category extends Equatable {
  final String id;
  final String name;
  final CategoryType type;
  final DateTime createdAt;
  final bool archived;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.archived = false,
  });

  @override
  List<Object?> get props => [id, name, type, createdAt, archived];

  @override
  String toString() => 'Category(id: $id, name: $name, type: $type, archived: $archived)';
}