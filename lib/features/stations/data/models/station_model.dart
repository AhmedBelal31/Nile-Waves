import 'package:hive/hive.dart';
import '../../domain/entities/station.dart';

part 'station_model.g.dart';

@HiveType(typeId: 0)
class StationModel extends Station {
  @HiveField(0)
  final String stationuuid;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String url;
  @HiveField(3)
  final String urlResolved;
  @HiveField(4)
  final String homepage;
  @HiveField(5)
  final String favicon;
  @HiveField(6)
  final String tags;
  @HiveField(7)
  final String countrycode;
  @HiveField(8)
  final int votes;

  const StationModel({
    required this.stationuuid,
    required this.name,
    required this.url,
    required this.urlResolved,
    required this.homepage,
    required this.favicon,
    required this.tags,
    required this.countrycode,
    required this.votes,
  }) : super(
          stationuuid: stationuuid,
          name: name,
          url: url,
          urlResolved: urlResolved,
          homepage: homepage,
          favicon: favicon,
          tags: tags,
          countrycode: countrycode,
          votes: votes,
        );

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      stationuuid: json['stationuuid'] ?? '',
      name: json['name'] ?? 'Unknown Station',
      url: json['url'] ?? '',
      urlResolved: json['url_resolved'] ?? '',
      homepage: json['homepage'] ?? '',
      favicon: json['favicon'] ?? '',
      tags: json['tags'] ?? '',
      countrycode: json['countrycode'] ?? '',
      votes: json['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stationuuid': stationuuid,
      'name': name,
      'url': url,
      'url_resolved': urlResolved,
      'homepage': homepage,
      'favicon': favicon,
      'tags': tags,
      'countrycode': countrycode,
      'votes': votes,
    };
  }

  factory StationModel.fromEntity(Station station) {
    return StationModel(
      stationuuid: station.stationuuid,
      name: station.name,
      url: station.url,
      urlResolved: station.urlResolved,
      homepage: station.homepage,
      favicon: station.favicon,
      tags: station.tags,
      countrycode: station.countrycode,
      votes: station.votes,
    );
  }
}
