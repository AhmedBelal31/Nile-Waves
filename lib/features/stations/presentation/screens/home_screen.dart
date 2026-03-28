import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../generated/l10n.dart';
import '../cubit/stations_cubit.dart';
import '../widgets/station_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/presentation/cubit/localization_cubit.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    context.read<StationsCubit>().loadStations();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppTheme.primary,
                width: 4,
              ),
            ),
          ),
          child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      // Header Typography
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeInDown(
                                duration: const Duration(milliseconds: 500),
                                child: Text(
                                  'Hello',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontSize: 18,
                                      ),
                                ),
                              ),
                              FadeInDown(
                                duration: const Duration(milliseconds: 500),
                                delay: const Duration(milliseconds: 100),
                                child: Text(
                                  'Listener',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
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
                      ),
                      const SizedBox(height: 32),

                      // Animated Search Box
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: TextField(
                          onChanged: (val) {
                            context.read<StationsCubit>().searchStations(val);
                          },
                          decoration: InputDecoration(
                            hintText: S.of(context).searchHint,
                            hintStyle: const TextStyle(color: AppTheme.textSecondary),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                            filled: false,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category Filters
                      FadeInRight(
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
                      ),
                      const SizedBox(height: 32),

                      // Custom Tabs exactly like design
                      FadeIn(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 300),
                        child: Row(
                          children: [
                            _buildCustomTab(S.of(context).all.toUpperCase(), 0),
                            const SizedBox(width: 24),
                            _buildCustomTab(S.of(context).favorites.toUpperCase(), 1),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tab Views
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAllStations(),
                            const FavoritesScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCustomTab(String title, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 24 : 0,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
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

  Widget _buildAllStations() {
    return BlocBuilder<StationsCubit, StationsState>(
      builder: (context, state) {
        if (state is StationsLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        } else if (state is StationsError) {
          return Center(
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
          );
        } else if (state is StationsLoaded) {
          final stations = state.stations;
          if (stations.isEmpty) {
            return const Center(child: Text("No stations found."));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<StationsCubit>().loadStations(forceRefresh: true);
            },
            color: AppTheme.primary,
            backgroundColor: AppTheme.surface,
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 120, top: 8), // clearance for miniplayer
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Matching sleek tall cards
              ),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                return StationCard(station: stations[index], index: index);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
