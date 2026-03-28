import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import '../../domain/entities/station.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../player/presentation/cubit/player_cubit.dart';
import '../cubit/stations_cubit.dart';

class StationCard extends StatefulWidget {
  final Station station;
  final int index;
  const StationCard({super.key, required this.station, required this.index});

  @override
  State<StationCard> createState() => _StationCardState();
}

class _StationCardState extends State<StationCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: widget.index * 50),
      child: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, playerState) {
          final isPlayingStation = playerState.currentStation?.stationuuid == widget.station.stationuuid;
          final isAudioPlaying = playerState.isPlaying;

          final bgColor = isPlayingStation ? AppTheme.primary : AppTheme.cardColor;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTapDown: (_) => _animController.forward(),
              onTapUp: (_) => _animController.reverse(),
              onTapCancel: () => _animController.reverse(),
              onDoubleTap: () {
                final stState = context.read<StationsCubit>().state;
                List<Station> currentList = [widget.station];
                if (stState is StationsLoaded) {
                  currentList = stState.stations;
                }
                context.read<PlayerCubit>().playStation(widget.station, queue: currentList);
              },
              child: AnimatedScale(
                scale: _isHovered ? 1.02 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (isPlayingStation || _isHovered)
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: _isHovered ? 0.5 : 0.3),
                            blurRadius: _isHovered ? 24 : 16,
                            offset: Offset(0, _isHovered ? 12 : 8),
                          )
                      ],
                    ),
                    child: Stack(
                  children: [
                    // Full Background Image
                    if (widget.station.favicon.isNotEmpty)
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: widget.station.favicon,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const SizedBox.shrink(),
                        ),
                      ),
                      
                    // Gradient overlay to ensure text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              bgColor.withValues(alpha: 0.5),
                              bgColor.withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ),
                      
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  _extractFreq(widget.station.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: isPlayingStation ? Colors.white : AppTheme.textMain,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 28,
                                      ),
                                ),
                              ),
                              BlocBuilder<FavoritesCubit, FavoritesState>(
                                builder: (context, favState) {
                                  bool isFav = false;
                                  if (favState is FavoritesLoaded) {
                                    isFav = favState.favorites.any((s) => s.stationuuid == widget.station.stationuuid);
                                  }
                                  return InkWell(
                                    onTap: () {
                                      context.read<FavoritesCubit>().toggleFavorite(widget.station);
                                    },
                                    child: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isPlayingStation ? Colors.white : AppTheme.primary,
                                      size: 22,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.station.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isPlayingStation ? Colors.white.withValues(alpha: 0.9) : AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                          ),
                          const Spacer(),
                          // Bottom Audio Wave
                          SizedBox(
                            height: 24,
                            child: isPlayingStation
                                ? MiniMusicVisualizer(
                                    color: Colors.white,
                                    width: 4,
                                    height: 24,
                                    radius: 2,
                                    animate: isAudioPlaying,
                                  )
                                : MiniMusicVisualizer(
                                    color: AppTheme.primary,
                                    width: 4,
                                    height: 24,
                                    radius: 2,
                                    animate: false, // static when inactive
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
      ),
    );
  }

  String _extractFreq(String name) {
    final exp = RegExp(r'\d{2,3}\.\d');
    final match = exp.firstMatch(name);
    if (match != null) return match.group(0)!;
    
    final lowerName = name.toLowerCase();
    if (lowerName.contains('quran') || lowerName.contains('قرآن')) return 'إذاعة';
    if (lowerName.contains('nogoum') || lowerName.contains('نجوم')) return 'EG';
    if (lowerName.contains('radio')) return 'Radio';
    
    final parts = name.split(' ');
    if (parts.isNotEmpty && parts[0].length <= 5) return parts[0];
    
    return 'EG';
  }
}
