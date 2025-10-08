import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class CategoriesLoadRequested extends CategoriesEvent {
  final CategoryType? filterType;

  const CategoriesLoadRequested({this.filterType});

  @override
  List<Object?> get props => [filterType];
}

class CategoryAddRequested extends CategoriesEvent {
  final String name;
  final CategoryType type;

  const CategoryAddRequested({
    required this.name,
    required this.type,
  });

  @override
  List<Object?> get props => [name, type];
}

class CategoryDeleteRequested extends CategoriesEvent {
  final String categoryId;

  const CategoryDeleteRequested(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class CategoriesFilterChanged extends CategoriesEvent {
  final CategoryType? filterType;

  const CategoriesFilterChanged({this.filterType});

  @override
  List<Object?> get props => [filterType];
}