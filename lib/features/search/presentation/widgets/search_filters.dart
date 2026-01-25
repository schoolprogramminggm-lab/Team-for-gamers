import 'package:flutter/material.dart';
import 'package:team_for_gamers/core/constants/app_constants.dart';

/// Виджет фильтров для поиска игроков
class SearchFilters extends StatelessWidget {
  final String? selectedGame;
  final String? selectedRank;
  final String? selectedRegion;
  final Function(String?) onGameChanged;
  final Function(String?) onRankChanged;
  final Function(String?) onRegionChanged;
  final VoidCallback onClearFilters;

  const SearchFilters({
    super.key,
    this.selectedGame,
    this.selectedRank,
    this.selectedRegion,
    required this.onGameChanged,
    required this.onRankChanged,
    required this.onRegionChanged,
    required this.onClearFilters,
  });

  bool get hasActiveFilters =>
      selectedGame != null || selectedRank != null || selectedRegion != null;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Фильтры',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (hasActiveFilters)
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Очистить'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Game Filter
            DropdownButtonFormField<String>(
              value: selectedGame,
              decoration: InputDecoration(
                labelText: 'Игра',
                prefixIcon: const Icon(Icons.sports_esports),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('Все игры'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Все игры'),
                ),
                ...GameConstants.popularGames.map((game) {
                  return DropdownMenuItem(
                    value: game,
                    child: Text(game),
                  );
                }).toList(),
              ],
              onChanged: onGameChanged,
            ),
            const SizedBox(height: 12),

            // Rank Filter
            DropdownButtonFormField<String>(
              value: selectedRank,
              decoration: InputDecoration(
                labelText: 'Ранг',
                prefixIcon: const Icon(Icons.emoji_events),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('Все ранги'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Все ранги'),
                ),
                ...RankConstants.ranks.map((rank) {
                  return DropdownMenuItem(
                    value: rank,
                    child: Text(rank),
                  );
                }).toList(),
              ],
              onChanged: onRankChanged,
            ),
            const SizedBox(height: 12),

            // Region Filter
            DropdownButtonFormField<String>(
              value: selectedRegion,
              decoration: InputDecoration(
                labelText: 'Регион',
                prefixIcon: const Icon(Icons.public),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('Все регионы'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Все регионы'),
                ),
                ...RegionConstants.regions.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
              ],
              onChanged: onRegionChanged,
            ),
          ],
        ),
      ),
    );
  }
}
