import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../generated/l10n.dart';
import '../cubit/stations_cubit.dart';
import '../widgets/station_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/presentation/cubit/localization_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = '';
  String? _userName;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StationsCubit>().loadStations();
    
    _loadUserName();
  }

  void _loadUserName() {
    final settingsBox = Hive.box('settings');
    final savedName = settingsBox.get('userName');
    if (savedName != null && savedName.toString().isNotEmpty) {
      setState(() {
        _userName = savedName;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNameDialog();
      });
    }
  }

  void _showNameDialog() {
    final TextEditingController nameController = TextEditingController(text: _userName ?? '');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            S.of(context).welcomeTo,
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).whatToCallYou,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: S.of(context).enterYourName,
                  hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primary),
                  ),
                ),
                onSubmitted: (value) => _saveName(nameController.text.trim()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _saveName(nameController.text.trim()),
              child: Text(S.of(context).letsGo, style: const TextStyle(color: AppTheme.primary)),
            )
          ],
        );
      }
    );
  }

  void _saveName(String name) {
    if (name.isNotEmpty) {
      Hive.box('settings').put('userName', name);
      setState(() {
        _userName = name;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppTheme.primary,
                width: 4,
              ),
            ),
          ),
          child: CustomScrollView(
            slivers: [
               SliverPadding(
                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
                 sliver: SliverList(
                   delegate: SliverChildListDelegate([
                      const SizedBox(height: 32),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildSearchBox(),
                      const SizedBox(height: 24),
                      _buildCategoryFilters(),
                      const SizedBox(height: 32),
                   ]),
                 ),
               ),
               
               // Favorites Section (Horizontal Carousel)
               SliverToBoxAdapter(
                 child: _buildFavoritesSection(),
               ),
               
               // All Stations Grid
               SliverPadding(
                 padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 120.0), // clearance for miniplayer
                 sliver: _buildAllStationsGrid(),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Text(
                S.of(context).hello,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 18,
                    ),
              ),
            ),
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: Row(
                children: [
                  Text(
                    _userName ?? S.of(context).listener,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showNameDialog,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.edit, size: 20, color: AppTheme.primary.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        FadeInRight(
          child: IconButton(
            icon: const Icon(Icons.language, color: AppTheme.primary, size: 28),
            onPressed: () {
              context.read<LocalizationCubit>().toggleLanguage();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 200),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return TextField(
            controller: _searchController,
            onChanged: (val) {
              context.read<StationsCubit>().searchStations(val);
            },
            decoration: InputDecoration(
              hintText: S.of(context).searchHint,
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
              suffixIcon: value.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        context.read<StationsCubit>().searchStations('');
                      },
                    )
                  : null,
              filled: false,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primary),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return FadeInRight(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 250),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildCategoryChip(Localizations.localeOf(context).languageCode == 'ar' ? 'الكل' : 'All', ''),
            _buildCategoryChip(Localizations.localeOf(context).languageCode == 'ar' ? 'قرآن وإسلامي' : 'Quran & Islamic', 'quran'),
            _buildCategoryChip(Localizations.localeOf(context).languageCode == 'ar' ? 'موسيقى' : 'Music', 'music'),
            _buildCategoryChip(Localizations.localeOf(context).languageCode == 'ar' ? 'هيتس وبوب' : 'Hits & Pop', 'hits'),
            _buildCategoryChip(Localizations.localeOf(context).languageCode == 'ar' ? 'كلاسيك' : 'Classic', 'classic'),
            _buildCategoryChip(Localizations.localeOf(context).languageCode == 'ar' ? 'دراما' : 'Drama', 'drama'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title, String tag) {
    bool isSelected = _selectedCategory == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = tag;
          });
          context.read<StationsCubit>().filterByCategory(tag);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state is FavoritesLoaded && state.favorites.isNotEmpty) {
          return FadeIn(
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    S.of(context).favorites.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220, // matching card aspect ratio visually
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: state.favorites.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          width: 160,
                          child: StationCard(
                            station: state.favorites[index], 
                            index: index,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAllStationsGrid() {
    return BlocBuilder<StationsCubit, StationsState>(
      builder: (context, state) {
        if (state is StationsLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        } else if (state is StationsError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: AppTheme.primary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    onPressed: () => context.read<StationsCubit>().loadStations(forceRefresh: true),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        } else if (state is StationsLoaded) {
          final stations = state.stations;
          if (stations.isEmpty) {
            return const SliverFillRemaining(
              child: Center(child: Text("No stations found.")),
            );
          }
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Matching sleek tall cards
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return StationCard(station: stations[index], index: index);
              },
              childCount: stations.length,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
