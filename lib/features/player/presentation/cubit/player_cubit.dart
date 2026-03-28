import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import '../../../stations/domain/entities/station.dart';
import '../../../../core/services/widget_service.dart';

part 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final AudioPlayer audioPlayer;
  
  PlayerCubit({required this.audioPlayer}) : super(const PlayerState()) {
    _initEngine();
    _initWidgetService();
  }

  void _initEngine() {
    audioPlayer.playerStateStream.listen((state) {
      final isPlaying = state.playing;
      emit(this.state.copyWith(
        isPlaying: isPlaying,
        processingState: state.processingState,
      ));
      // Sync play state to widget
      _syncWidgetState();
    });
    audioPlayer.volumeStream.listen((volume) {
      emit(state.copyWith(volume: volume));
    });
  }

  void _initWidgetService() {
    WidgetService.init(
      onWidgetPlay: () => _handleWidgetPlay(),
      onWidgetPause: () => _handleWidgetPause(),
    );
  }

  void _handleWidgetPlay() async {
    if (state.currentStation != null) {
      await audioPlayer.play();
    }
  }

  void _handleWidgetPause() async {
    await audioPlayer.pause();
  }

  void _syncWidgetState() {
    final stationName = state.currentStation?.name ?? 'Nile Waves';
    WidgetService.updateWidget(
      stationName: stationName,
      isPlaying: state.isPlaying,
    );
  }

  Future<void> playStation(Station station, {List<Station>? queue}) async {
    final updatedQueue = queue ?? state.queue;
    emit(state.copyWith(currentStation: station, queue: updatedQueue));
    try {
      final url = station.urlResolved.isNotEmpty ? station.urlResolved : station.url;
      await audioPlayer.setUrl(url);
      await audioPlayer.play();

      // Save last station to widget SharedPreferences
      WidgetService.saveLastStation(
        stationName: station.name,
        stationUrl: url,
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load audio stream'));
    }
  }

  Future<void> playNext() async {
    if (state.queue.isEmpty || state.currentStation == null) return;
    int currentIndex = state.queue.indexWhere((s) => s.stationuuid == state.currentStation!.stationuuid);
    if (currentIndex != -1) {
      int nextIndex = (currentIndex + 1) % state.queue.length;
      await playStation(state.queue[nextIndex], queue: state.queue);
    }
  }

  Future<void> playPrevious() async {
    if (state.queue.isEmpty || state.currentStation == null) return;
    int currentIndex = state.queue.indexWhere((s) => s.stationuuid == state.currentStation!.stationuuid);
    if (currentIndex != -1) {
      int prevIndex = (currentIndex - 1) < 0 ? state.queue.length - 1 : currentIndex - 1;
      await playStation(state.queue[prevIndex], queue: state.queue);
    }
  }

  Future<void> togglePlayPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> setVolume(double volume) async {
    await audioPlayer.setVolume(volume);
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}
