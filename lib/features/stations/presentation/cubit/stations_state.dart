part of 'stations_cubit.dart';

abstract class StationsState extends Equatable {
  const StationsState();

  @override
  List<Object> get props => [];
}

class StationsInitial extends StationsState {}

class StationsLoading extends StationsState {}

class StationsLoaded extends StationsState {
  final List<Station> stations;

  const StationsLoaded({required this.stations});

  @override
  List<Object> get props => [stations];
}

class StationsError extends StationsState {
  final String message;

  const StationsError({required this.message});

  @override
  List<Object> get props => [message];
}
