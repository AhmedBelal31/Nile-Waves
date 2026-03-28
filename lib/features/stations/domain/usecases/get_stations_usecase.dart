import '../../../../core/error/failures.dart';
import '../entities/station.dart';
import '../repositories/station_repository.dart';

class GetStationsUseCase {
  final StationRepository repository;

  GetStationsUseCase(this.repository);

  Future<(Failure?, List<Station>?)> call({bool forceRefresh = false}) async {
    return await repository.getStations(forceRefresh: forceRefresh);
  }
}
