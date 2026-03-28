import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/station.dart';
import '../../domain/usecases/get_stations_usecase.dart';

part 'stations_state.dart';

class StationsCubit extends Cubit<StationsState> {
  final GetStationsUseCase getStationsUseCase;
  List<Station> _allStations = [];

  StationsCubit({required this.getStationsUseCase}) : super(StationsInitial());

  Future<void> loadStations({bool forceRefresh = false}) async {
    emit(StationsLoading());
    final result = await getStationsUseCase(forceRefresh: forceRefresh);
    final failure = result.$1;
    final stations = result.$2;

    if (failure != null) {
      emit(StationsError(message: failure.message));
    } else if (stations != null) {
      _allStations = stations;

      // Extract and print all unique tags for categorization
      final Set<String> allTags = {};
      for (var s in stations) {
        if (s.tags.isNotEmpty) {
          final tagsList = s.tags.split(',').map((t) => t.trim().toLowerCase());
          allTags.addAll(tagsList);
        }
      }
      print('=================== ALL STATION TAGS ===================');
      final sortedTags = allTags.toList()..sort();
      for (var tag in sortedTags) {
        if (tag.isNotEmpty) {
          print('TAG: $tag');
        }
      }
      print('========================================================');

      emit(StationsLoaded(stations: _allStations));
    }
  }

  void searchStations(String query) {
    if (query.isEmpty) {
      emit(StationsLoaded(stations: _allStations));
      return;
    }
    final filtered = _allStations.where((s) {
      return s.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    emit(StationsLoaded(stations: filtered));
  }

  static const Map<String, List<String>> _categoryTags = {
    'quran': ['اسلامي', 'القرآن', 'القرآن الكريم', 'دين', 'قران كريم', 'مسلم'],
    'music': ['arabic music'],
    'hits': ['classic hits', 'hits', 'pop'],
    'classic': ['classical'],
    'drama': ['radio drama', 'radiodrama', 'romance'],
  };

  void filterByCategory(String category) {
    if (_allStations.isEmpty) return;
    
    if (category.isEmpty) {
      emit(StationsLoaded(stations: _allStations));
    } else {
      final validTags = _categoryTags[category] ?? [category];
      
      final filtered = _allStations.where((station) {
        final stationTagsLower = station.tags.toLowerCase();
        return validTags.any((tag) => stationTagsLower.contains(tag.toLowerCase()));
      }).toList();
      
      emit(StationsLoaded(stations: filtered));
    }
  }
}
