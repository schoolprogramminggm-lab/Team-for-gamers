import 'package:flutter/material.dart';
import 'package:team_for_gamers/core/constants/app_constants.dart';

/// Виджет для выбора любимых игр (multi-select)
class GameSelector extends StatefulWidget {
  final List<String> selectedGames;
  final Function(List<String>) onChanged;

  const GameSelector({
    super.key,
    required this.selectedGames,
    required this.onChanged,
  });

  @override
  State<GameSelector> createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {
  late List<String> _selectedGames;

  @override
  void initState() {
    super.initState();
    _selectedGames = List.from(widget.selectedGames);
  }

  void _toggleGame(String game) {
    setState(() {
      if (_selectedGames.contains(game)) {
        _selectedGames.remove(game);
      } else {
        _selectedGames.add(game);
      }
    });
    widget.onChanged(_selectedGames);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Любимые игры',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GameConstants.popularGames.map((game) {
            final isSelected = _selectedGames.contains(game);
            return FilterChip(
              label: Text(game),
              selected: isSelected,
              onSelected: (_) => _toggleGame(game),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedGames.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Выбрано: ${_selectedGames.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ],
    );
  }
}
