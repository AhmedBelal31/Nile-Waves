import '../../../../core/error/failures.dart';
import '../entities/station.dart';
import '../repositories/station_repository.dart';

class ManageFavoritesUseCase {
  final StationRepository repository;

  ManageFavoritesUseCase(this.repository);

  Future<(Failure?, List<Station>?)> getFavorites() async {
    return await repository.getFavorites();
  }

  Future<(Failure?, bool?)> toggleFavorite(Station station) async {
    return await repository.toggleFavorite(station);
  }
  
  Future<(Failure?, bool?)> isFavorite(String stationuuid) async {
    return await repository.isFavorite(stationuuid);
  }
}
