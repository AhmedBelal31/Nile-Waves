import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/favorites_cubit.dart';
import '../../../stations/presentation/widgets/station_card.dart';
import '../../../../core/theme/app_theme.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state is FavoritesLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        } else if (state is FavoritesLoaded) {
          final favorites = state.favorites;
          if (favorites.isEmpty) {
            return Center(
              child: Text(
                'No favorites added yet.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 120, top: 8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return StationCard(station: favorites[index], index: index);
            },
          );
        } else if (state is FavoritesError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
