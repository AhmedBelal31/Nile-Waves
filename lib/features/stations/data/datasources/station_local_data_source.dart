import 'package:hive/hive.dart';
import '../models/station_model.dart';

abstract class StationLocalDataSource {
  Future<List<StationModel>> getFavorites();
  Future<void> saveFavorite(StationModel station);
  Future<void> removeFavorite(String stationuuid);
  Future<bool> isFavorite(String stationuuid);
}

class StationLocalDataSourceImpl implements StationLocalDataSource {
  static const String _favoritesBox = 'favoritesBox';

  Future<Box<StationModel>> get _box async => await Hive.openBox<StationModel>(_favoritesBox);

  @override
  Future<List<StationModel>> getFavorites() async {
    final box = await _box;
    return box.values.toList();
  }

  @override
  Future<void> saveFavorite(StationModel station) async {
    final box = await _box;
    await box.put(station.stationuuid, station);
  }

  @override
  Future<void> removeFavorite(String stationuuid) async {
    final box = await _box;
    await box.delete(stationuuid);
  }

  @override
  Future<bool> isFavorite(String stationuuid) async {
    final box = await _box;
    return box.containsKey(stationuuid);
  }
}
class CacheException implements Exception {}
