import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories_by_type.dart';
import '../../domain/repositories/category_repository.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final AddCategory _addCategory;
  final DeleteCategory _deleteCategory;
  final GetCategoriesByType _getCategoriesByType;
  final CategoryRepository _categoryRepository;

  CategoriesBloc({
    required AddCategory addCategory,
    required DeleteCategory deleteCategory,
    required GetCategoriesByType getCategoriesByType,
    required CategoryRepository categoryRepository,
  })  : _addCategory = addCategory,
        _deleteCategory = deleteCategory,
        _getCategoriesByType = getCategoriesByType,
        _categoryRepository = categoryRepository,
        super(const CategoriesInitial()) {
    on<CategoriesLoadRequested>(_onCategoriesLoadRequested);
    on<CategoryAddRequested>(_onCategoryAddRequested);
    on<CategoryDeleteRequested>(_onCategoryDeleteRequested);
    on<CategoriesFilterChanged>(_onCategoriesFilterChanged);
  }

  Future<void> _onCategoriesLoadRequested(
    CategoriesLoadRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());

    final result = event.filterType != null
        ? await _getCategoriesByType(event.filterType!)
        : await _categoryRepository.getCategories();

    await result.fold(
      onSuccess: (categories) async {
        if (categories.isEmpty) {
          emit(CategoriesEmpty(currentFilter: event.filterType));
        } else {
          emit(CategoriesLoaded(
            categories: categories,
            currentFilter: event.filterType,
          ));
        }
      },
      onFailure: (message) async {
        emit(CategoriesError(message));
      },
    );
  }

  Future<void> _onCategoryAddRequested(
    CategoryAddRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state is CategoriesLoaded) {
      final currentState = state as CategoriesLoaded;
      emit(CategoryOperationInProgress(
        categories: currentState.categories,
        currentFilter: currentState.currentFilter,
      ));
    }

    final result = await _addCategory(
      name: event.name,
      type: event.type,
    );

    await result.fold(
      onSuccess: (newCategory) async {
        // Reload categories to get updated list
        add(CategoriesLoadRequested(
          filterType: state is CategoriesLoaded 
              ? (state as CategoriesLoaded).currentFilter
              : null,
        ));
      },
      onFailure: (message) async {
        emit(CategoriesError(message));
      },
    );
  }

  Future<void> _onCategoryDeleteRequested(
    CategoryDeleteRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state is CategoriesLoaded) {
      final currentState = state as CategoriesLoaded;
      emit(CategoryOperationInProgress(
        categories: currentState.categories,
        currentFilter: currentState.currentFilter,
      ));
    }

    final result = await _deleteCategory(event.categoryId);

    await result.fold(
      onSuccess: (deleted) async {
        if (deleted) {
          // Reload categories to get updated list
          add(CategoriesLoadRequested(
            filterType: state is CategoryOperationInProgress 
                ? (state as CategoryOperationInProgress).currentFilter
                : null,
          ));
        } else {
          emit(const CategoriesError('Failed to delete category'));
        }
      },
      onFailure: (message) async {
        emit(CategoriesError(message));
      },
    );
  }

  Future<void> _onCategoriesFilterChanged(
    CategoriesFilterChanged event,
    Emitter<CategoriesState> emit,
  ) async {
    add(CategoriesLoadRequested(filterType: event.filterType));
  }
}