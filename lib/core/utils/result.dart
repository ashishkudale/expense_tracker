import 'package:equatable/equatable.dart';

abstract class Result<T> extends Equatable {
  const Result();
  
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  
  T? get data => isSuccess ? (this as Success<T>).data : null;
  String? get error => isFailure ? (this as Failure<T>).message : null;
  
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as Failure<T>).message);
    }
  }
}

class Success<T> extends Result<T> {
  @override
  final T data;
  
  const Success(this.data);
  
  @override
  List<Object?> get props => [data];
}

class Failure<T> extends Result<T> {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}