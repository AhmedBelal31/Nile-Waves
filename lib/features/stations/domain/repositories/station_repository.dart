import '../../../../core/error/failures.dart';
import '../entities/station.dart';

abstract class StationRepository {
  Future<(Failure?, List<Station>?)> getStations({bool forceRefresh = false});
  Future<(Failure?, List<Station>?)> getFavorites();
  Future<(Failure?, bool?)> toggleFavorite(Station station);
  Future<(Failure?, bool?)> isFavorite(String stationuuid);
}
