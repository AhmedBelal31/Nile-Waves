import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../cubit/player_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../widgets/tuner_widget.dart';
import '../widgets/background_wave_painter.dart';

class FullPlayerScreen extends StatefulWidget {
  final bool isDesktopPanel;
  const FullPlayerScreen({super.key, this.isDesktopPanel = false});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
        vsync: this, duration: const Duration(seconds: 20));
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerCubit, PlayerState>(
      listener: (context, state) {
        if (state.isPlaying && !_spinController.isAnimating) {
          _spinController.repeat();
        } else if (!state.isPlaying && _spinController.isAnimating) {
          _spinController.stop();
        }
      },
      builder: (context, state) {
        final station = state.currentStation;
        if (station == null) return Container(color: AppTheme.background);

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Row(
              children: [
                  // Left Red Border
                  Container(
                    width: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          const SizedBox(height: 10),
                          // Top bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                                onPressed: () {
                                  // Nav handled externally by Miniplayer drag, this is visual
                                  Navigator.maybePop(context);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_horiz, color: AppTheme.textSecondary),
                                onPressed: () {},
                              )
                            ],
                          ),
                          const SizedBox(height: 60),

                          // Massive Animated Vinyl Centerpiece
                          FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing Breathing Halos
                                if (state.isPlaying)
                                  Pulse(
                                    infinite: true,
                                    duration: const Duration(seconds: 3),
                                    child: Container(
                                      width: 260,
                                      height: 260,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.primary.withValues(alpha: 0.1),
                                      ),
                                    ),
                                  ),
                                  
                                // Heartbeat Halo Ring
                                if (state.isPlaying)
                                  Pulse(
                                    infinite: true,
                                    duration: const Duration(seconds: 4),
                                    child: Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.primary.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),

                                // Rotating Vinyl Art
                                RotationTransition(
                                  turns: _spinController,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppTheme.surface, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: station.favicon.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: station.favicon,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url, error) => _buildFallbackRecord(),
                                            )
                                          : _buildFallbackRecord(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Epic Frequency Display + Wave Background
                          if (_extractFreq(station.name) != 'N/A') ...[
                            SizedBox(
                              height: 120,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Custom animated wave background
                                  FadeIn(
                                    duration: const Duration(seconds: 1),
                                    child: Opacity(
                                      opacity: state.isPlaying ? 0.3 : 0.1,
                                      child: CustomPaint(
                                        size: const Size(double.infinity, 100),
                                        painter: BackgroundWavePainter(color: AppTheme.primary),
                                      ),
                                    ),
                                  ),
                                  FadeInDown(
                                    duration: const Duration(milliseconds: 600),
                                    child: Text(
                                      _extractFreq(station.name),
                                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                            fontSize: 72,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))
                                            ],
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],

                          // Favorite Button
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            child: BlocBuilder<FavoritesCubit, FavoritesState>(
                              builder: (context, favState) {
                                bool isFav = false;
                                if (favState is FavoritesLoaded) {
                                  isFav = favState.favorites.any((s) => s.stationuuid == station.stationuuid);
                                }
                                return IconButton(
                                  icon: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: AppTheme.primary,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    context.read<FavoritesCubit>().toggleFavorite(station);
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 700),
                            child: Text(
                              station.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            child: Text(
                              station.tags.isNotEmpty ? station.tags : 'Egypt Radio',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          // Dynamic Sound Wave Visualizer
                          if (state.isPlaying)
                            FadeInUp(
                              duration: const Duration(milliseconds: 900),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: SiriWaveform.ios7(
                                  controller: IOS7SiriWaveformController(
                                    amplitude: 0.5,
                                    color: AppTheme.primary,
                                    frequency: 4,
                                    speed: 0.15,
                                  ),
                                  options: const IOS7SiriWaveformOptions(
                                    height: 50,
                                    width: 250,
                                  ),
                                ),
                              ),
                            ),

                          // const SizedBox(height: 60),

                          // // Tuner
                          // FadeInDown(
                          //   duration: const Duration(milliseconds: 600),
                          //   child: TunerWidget(
                          //     currentFreq: _parseFreqNum(station.name),
                          //   ),
                          // ),

                          const SizedBox(height: 40),

                          // Volume
                          Row(
                            children: [
                              const Icon(Icons.volume_down, color: AppTheme.textSecondary),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2,
                                    activeTrackColor: AppTheme.primary,
                                    inactiveTrackColor: AppTheme.textSecondary.withValues(alpha: 0.3),
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    thumbColor: AppTheme.primary,
                                  ),
                                  child: Slider(
                                    value: state.volume,
                                    onChanged: (val) {
                                      context.read<PlayerCubit>().setVolume(val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Playback
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: ShapeDecoration(
                                  color: AppTheme.surface,
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.skip_previous, color: AppTheme.textSecondary),
                                  onPressed: () {
                                    context.read<PlayerCubit>().playPrevious();
                                  },
                                ),
                              ),
                              const SizedBox(width: 32),
                              Container(
                                width: 80,
                                height: 80,
                                padding: const EdgeInsets.all(8),
                                decoration: ShapeDecoration(
                                  color: AppTheme.primary,
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(56),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  iconSize: 40,
                                  icon: Icon(
                                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    context.read<PlayerCubit>().togglePlayPause();
                                  },
                                ),
                              ),
                              const SizedBox(width: 32),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: ShapeDecoration(
                                  color: AppTheme.surface,
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.skip_next, color: AppTheme.textSecondary),
                                  onPressed: () {
                                    context.read<PlayerCubit>().playNext();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _extractFreq(String name) {
    final exp = RegExp(r'\d{2,3}\.\d');
    final match = exp.firstMatch(name);
    return match?.group(0) ?? 'N/A';
  }

  double _parseFreqNum(String name) {
    final str = _extractFreq(name);
    return double.tryParse(str) ?? 98.3;
  }

  // Beautiful fallback UI for missing specific station art
  Widget _buildFallbackRecord() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppTheme.cardColor, Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner vinyl grooves
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 1),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 1),
            ),
          ),
          const Icon(Icons.radio, size: 60, color: AppTheme.primary),
        ],
      ),
    );
  }
}
