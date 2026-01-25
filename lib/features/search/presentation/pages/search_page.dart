import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/app/routes/app_routes.dart';
import 'package:team_for_gamers/features/search/presentation/widgets/player_card.dart';
import 'package:team_for_gamers/features/search/presentation/widgets/search_filters.dart';
import 'package:team_for_gamers/features/search/providers/search_provider.dart';

/// Страница поиска игроков
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery(String query) {
    final currentFilters = ref.read(searchFiltersProvider);
    ref.read(searchFiltersProvider.notifier).state = currentFilters.copyWith(
      searchQuery: query.isEmpty ? null : query,
      clearQuery: query.isEmpty,
    );
  }

  void _clearFilters() {
    ref.read(searchFiltersProvider.notifier).state = const SearchFiltersState();
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск игроков'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по имени...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _updateSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _updateSearchQuery,
            ),
          ),

          // Filters
          SearchFilters(
            selectedGame: filters.game,
            selectedRank: filters.rank,
            selectedRegion: filters.region,
            onGameChanged: (game) {
              ref.read(searchFiltersProvider.notifier).state =
                  filters.copyWith(game: game, clearGame: game == null);
            },
            onRankChanged: (rank) {
              ref.read(searchFiltersProvider.notifier).state =
                  filters.copyWith(rank: rank, clearRank: rank == null);
            },
            onRegionChanged: (region) {
              ref.read(searchFiltersProvider.notifier).state =
                  filters.copyWith(region: region, clearRegion: region == null);
            },
            onClearFilters: _clearFilters,
          ),

          // Results
          Expanded(
            child: searchResults.when(
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Игроки не найдены',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Попробуйте изменить фильтры',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return PlayerCard(
                      user: user,
                      onTap: () {
                        context.push('${AppRoutes.userDetails.replaceAll(':userId', user.id)}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
