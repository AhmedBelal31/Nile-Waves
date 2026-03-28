import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import '../network/dio_client.dart';
// Data Sources
import '../../features/stations/data/datasources/station_local_data_source.dart';
import '../../features/stations/data/datasources/station_remote_data_source.dart';
// Repositories
import '../../features/stations/domain/repositories/station_repository.dart';
import '../../features/stations/data/repositories/station_repository_impl.dart';
// Use Cases
import '../../features/stations/domain/usecases/get_stations_usecase.dart';
import '../../features/stations/domain/usecases/manage_favorites_usecase.dart';
// Cubits
import '../../features/stations/presentation/cubit/stations_cubit.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/player/presentation/cubit/player_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  // Data Sources
  sl.registerLazySingleton<StationRemoteDataSource>(
    () => StationRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<StationLocalDataSource>(
    () => StationLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<StationRepository>(
    () => StationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetStationsUseCase(sl()));
  sl.registerLazySingleton(() => ManageFavoritesUseCase(sl()));

  // Cubits - Registered as Factory because we might want fresh instances or they manage their own lifecycle via UI
  sl.registerFactory(() => StationsCubit(getStationsUseCase: sl()));
  sl.registerFactory(() => FavoritesCubit(manageFavoritesUseCase: sl()));
  
  // Player Cubit as a singleton or lazy singleton so that the mini player and full player share the exact same state and audio engine
  sl.registerLazySingleton(() => PlayerCubit(audioPlayer: sl()));
}
