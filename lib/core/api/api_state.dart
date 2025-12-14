import 'package:equatable/equatable.dart';

// Api Network State
abstract class ApiState<T> extends Equatable {
  const ApiState();

  @override
  List<Object?> get props => [];
}

// Api Network Initial State
class ApiInitialState<T> extends ApiState<T> {
  const ApiInitialState();
}

// Api Network Loading State
class ApiLoadingState<T> extends ApiState<T> {
  const ApiLoadingState();

  @override
  List<Object?> get props => [...super.props];
}

// Api Network Loaded State
class ApiLoadedState<T> extends ApiState<T> {
  const ApiLoadedState({
    required this.data,
    required this.statusCode,
    this.message,
  });

  final T data;
  final int statusCode;
  final String? message;

  @override
  List<Object?> get props => [...super.props, data, message, statusCode];
}

// Api Network Error State
class ApiErrorState<T> extends ApiState<T> {
  const ApiErrorState({required this.error, this.statusCode});

  final String error;
  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, error, statusCode];
}
