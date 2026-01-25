import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/app/routes/app_routes.dart';
import 'package:team_for_gamers/core/constants/app_constants.dart';
import 'package:team_for_gamers/features/auth/providers/auth_provider.dart';
import 'package:team_for_gamers/features/teams/presentation/widgets/team_card.dart';
import 'package:team_for_gamers/features/teams/providers/team_provider.dart';

/// Страница списка команд
class TeamsPage extends ConsumerStatefulWidget {
  const TeamsPage({super.key});

  @override
  ConsumerState<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends ConsumerState<TeamsPage> {
  int _selectedTab = 0; // 0 = Все команды, 1 = Мои команды
  String? _selectedGame;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    final teamsAsyncValue = _selectedTab == 0
        ? (_selectedGame == null
            ? ref.watch(allTeamsProvider)
            : ref.watch(teamsByGameProvider(_selectedGame!)))
        : (currentUser != null
            ? ref.watch(userTeamsProvider(currentUser.uid))
            : const AsyncValue.data([]));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Команды'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Все команды'),
                  icon: Icon(Icons.public),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Мои команды'),
                  icon: Icon(Icons.person),
                ),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedTab = newSelection.first;
                  _selectedGame = null; // Reset filter when switching tabs
                });
              },
            ),
          ),
          // Game Filter
          if (_selectedTab == 0) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedGame,
                decoration: InputDecoration(
                  labelText: 'Фильтр по игре',
                  prefixIcon: const Icon(Icons.sports_esports),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                onChanged: (value) {
                  setState(() => _selectedGame = value);
                },
              ),
            ),
          ],

          // Teams List
          Expanded(
            child: teamsAsyncValue.when(
              data: (teams) {
                if (teams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedTab == 0
                              ? 'Команды не найдены'
                              : 'Вы еще не состоите в командах',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedTab == 0
                              ? 'Попробуйте изменить фильтр'
                              : 'Создайте свою команду или вступите в существующую',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return TeamCard(
                      team: team,
                      onTap: () {
                        context.push('${AppRoutes.teamDetails.replaceAll(':teamId', team.id)}');
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.createTeam);
        },
        icon: const Icon(Icons.add),
        label: const Text('Создать команду'),
      ),
    );
  }
}
