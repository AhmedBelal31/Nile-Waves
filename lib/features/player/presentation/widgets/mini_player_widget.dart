import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:miniplayer/miniplayer.dart';
import '../../../player/presentation/cubit/player_cubit.dart';
import '../../../stations/domain/entities/station.dart';
import '../../../../core/theme/app_theme.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final station = state.currentStation;
        if (station == null) return const SizedBox.shrink();

        return Container(
          color: AppTheme.background, // Match scaffold background precisely
          child: Row(
            children: [
                // Red indicator for currently active area
                Container(
                  width: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Volume slider matching full UI
                          Row(
                            children: [
                              const Icon(Icons.volume_down, color: AppTheme.textSecondary, size: 16),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    activeTrackColor: AppTheme.primary,
                                    inactiveTrackColor: AppTheme.textSecondary.withValues(alpha: 0.3),
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
                          // Playback controls matching UI
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: ShapeDecoration(
                                  color: AppTheme.surface,
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.skip_previous, color: AppTheme.textSecondary, size: 20),
                                  onPressed: () {
                                    context.read<PlayerCubit>().playPrevious();
                                  },
                                ),
                              ),
                              const SizedBox(width: 24),
                              Container(
                                width: 52,
                                height: 52,
                                decoration: ShapeDecoration(
                                  color: AppTheme.primary,
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    context.read<PlayerCubit>().togglePlayPause();
                                  },
                                ),
                              ),
                              const SizedBox(width: 24),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: ShapeDecoration(
                                  color: AppTheme.surface,
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.skip_next, color: AppTheme.textSecondary, size: 20),
                                  onPressed: () {
                                    context.read<PlayerCubit>().playNext();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
