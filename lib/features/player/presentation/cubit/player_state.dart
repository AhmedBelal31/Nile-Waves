part of 'player_cubit.dart';

class PlayerState extends Equatable {
  final Station? currentStation;
  final List<Station> queue;
  final bool isPlaying;
  final ProcessingState processingState;
  final double volume;
  final String? error;

  const PlayerState({
    this.currentStation,
    this.queue = const [],
    this.isPlaying = false,
    this.processingState = ProcessingState.idle,
    this.volume = 1.0,
    this.error,
  });

  PlayerState copyWith({
    Station? currentStation,
    List<Station>? queue,
    bool? isPlaying,
    ProcessingState? processingState,
    double? volume,
    String? error,
    bool clearError = false,
  }) {
    return PlayerState(
      currentStation: currentStation ?? this.currentStation,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      processingState: processingState ?? this.processingState,
      volume: volume ?? this.volume,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [currentStation, queue, isPlaying, processingState, volume, error];
}
