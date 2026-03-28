import '../../../../core/error/failures.dart';
import '../../domain/entities/station.dart';
import '../../domain/repositories/station_repository.dart';
import '../datasources/station_local_data_source.dart';
import '../datasources/station_remote_data_source.dart';
import '../models/station_model.dart';

class StationRepositoryImpl implements StationRepository {
  final StationRemoteDataSource remoteDataSource;
  final StationLocalDataSource localDataSource;

  StationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<(Failure?, List<Station>?)> getStations({bool forceRefresh = false}) async {
    try {
      final remoteStations = await remoteDataSource.getStations();
      return (null, remoteStations);
    } on ServerException {
      return (const ServerFailure('Failed to fetch stations from server'), null);
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, List<Station>?)> getFavorites() async {
    try {
      final localFavorites = await localDataSource.getFavorites();
      return (null, localFavorites);
    } catch (e) {
      return (CacheFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, bool?)> isFavorite(String stationuuid) async {
    try {
      final isFav = await localDataSource.isFavorite(stationuuid);
      return (null, isFav);
    } catch (e) {
      return (CacheFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, bool?)> toggleFavorite(Station station) async {
    try {
      final isFav = await localDataSource.isFavorite(station.stationuuid);
      if (isFav) {
        await localDataSource.removeFavorite(station.stationuuid);
        return (null, false);
      } else {
        await localDataSource.saveFavorite(StationModel.fromEntity(station));
        return (null, true);
      }
    } catch (e) {
      return (CacheFailure(e.toString()), null);
    }
  }
}
