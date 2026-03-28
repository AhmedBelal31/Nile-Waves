import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/failures.dart';
import '../models/station_model.dart';

abstract class StationRemoteDataSource {
  Future<List<StationModel>> getStations();
}

class StationRemoteDataSourceImpl implements StationRemoteDataSource {
  final DioClient dioClient;

  StationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<StationModel>> getStations() async {
    try {
      final response = await dioClient.get(
        ApiConstants.stationsSearch,
        queryParameters: {
          'countrycode': 'EG',
          'order': 'clickcount',
          'reverse': 'true',
          'hidebroken': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StationModel.fromJson(Map<String,dynamic>.from(json))).toList();
      } else {
        throw const ServerException();
      }
    } on DioException catch (_) {
      throw const ServerException();
    }
  }
}

class ServerException implements Exception {
  const ServerException();
}
