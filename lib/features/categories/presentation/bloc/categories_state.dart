import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;
  final CategoryType? currentFilter;

  const CategoriesLoaded({
    required this.categories,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [categories, currentFilter];

  CategoriesLoaded copyWith({
    List<Category>? categories,
    CategoryType? currentFilter,
  }) {
    return CategoriesLoaded(
      categories: categories ?? this.categories,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class CategoriesEmpty extends CategoriesState {
  final CategoryType? currentFilter;

  const CategoriesEmpty({this.currentFilter});

  @override
  List<Object?> get props => [currentFilter];
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryOperationInProgress extends CategoriesState {
  final List<Category> categories;
  final CategoryType? currentFilter;

  const CategoryOperationInProgress({
    required this.categories,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [categories, currentFilter];
}