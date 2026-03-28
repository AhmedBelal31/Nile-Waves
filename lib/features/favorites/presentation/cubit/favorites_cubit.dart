import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../stations/domain/entities/station.dart';
import '../../../stations/domain/usecases/manage_favorites_usecase.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final ManageFavoritesUseCase manageFavoritesUseCase;

  FavoritesCubit({required this.manageFavoritesUseCase}) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    final result = await manageFavoritesUseCase.getFavorites();
    if (result.$1 != null) {
      emit(FavoritesError(message: result.$1!.message));
    } else {
      emit(FavoritesLoaded(favorites: result.$2 ?? []));
    }
  }

  Future<void> toggleFavorite(Station station) async {
    await manageFavoritesUseCase.toggleFavorite(station);
    // Reload favorites
    final result = await manageFavoritesUseCase.getFavorites();
    if (result.$2 != null) {
      emit(FavoritesLoaded(favorites: result.$2!));
    }
  }

  Future<bool> isFavorite(String stationuuid) async {
    final result = await manageFavoritesUseCase.isFavorite(stationuuid);
    return result.$2 ?? false;
  }
}
