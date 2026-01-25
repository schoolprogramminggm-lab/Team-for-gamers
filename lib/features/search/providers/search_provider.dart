import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_for_gamers/features/profile/data/models/user_model.dart';
import 'package:team_for_gamers/features/profile/providers/user_provider.dart';

/// Состояние фильтров поиска
class SearchFiltersState {
  final String? game;
  final String? rank;
  final String? region;
  final String? searchQuery;

  const SearchFiltersState({
    this.game,
    this.rank,
    this.region,
    this.searchQuery,
  });

  SearchFiltersState copyWith({
    String? game,
    String? rank,
    String? region,
    String? searchQuery,
    bool clearGame = false,
    bool clearRank = false,
    bool clearRegion = false,
    bool clearQuery = false,
  }) {
    return SearchFiltersState(
      game: clearGame ? null : (game ?? this.game),
      rank: clearRank ? null : (rank ?? this.rank),
      region: clearRegion ? null : (region ?? this.region),
      searchQuery: clearQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  bool get hasFilters =>
      game != null || rank != null || region != null || searchQuery != null;
}

/// Провайдер для состояния фильтров
final searchFiltersProvider =
    StateProvider<SearchFiltersState>((ref) => const SearchFiltersState());

/// Провайдер для результатов поиска
final searchResultsProvider = FutureProvider<List<UserModel>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final repository = ref.watch(userRepositoryProvider);

  // Если нет фильтров, показываем всех пользователей
  if (!filters.hasFilters) {
    return await repository.getAllUsers();
  }

  // Применяем фильтры
  return await repository.searchUsers(
    game: filters.game,
    rank: filters.rank,
    region: filters.region,
    nameQuery: filters.searchQuery,
  );
});
