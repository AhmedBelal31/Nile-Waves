import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final String stationuuid;
  final String name;
  final String url;
  final String urlResolved;
  final String homepage;
  final String favicon;
  final String tags;
  final String countrycode;
  final int votes;

  const Station({
    required this.stationuuid,
    required this.name,
    required this.url,
    required this.urlResolved,
    required this.homepage,
    required this.favicon,
    required this.tags,
    required this.countrycode,
    required this.votes,
  });

  @override
  List<Object?> get props => [
        stationuuid,
        name,
        url,
        urlResolved,
        homepage,
        favicon,
        tags,
        countrycode,
        votes,
      ];
      
  Station copyWith({
    String? stationuuid,
    String? name,
    String? url,
    String? urlResolved,
    String? homepage,
    String? favicon,
    String? tags,
    String? countrycode,
    int? votes,
  }) {
    return Station(
      stationuuid: stationuuid ?? this.stationuuid,
      name: name ?? this.name,
      url: url ?? this.url,
      urlResolved: urlResolved ?? this.urlResolved,
      homepage: homepage ?? this.homepage,
      favicon: favicon ?? this.favicon,
      tags: tags ?? this.tags,
      countrycode: countrycode ?? this.countrycode,
      votes: votes ?? this.votes,
    );
  }
}
