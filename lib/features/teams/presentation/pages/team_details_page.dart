import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/app/routes/app_routes.dart';
import 'package:team_for_gamers/features/auth/providers/auth_provider.dart';
import 'package:team_for_gamers/features/teams/providers/team_provider.dart';


/// Страница деталей команды
class TeamDetailsPage extends ConsumerWidget {
  final String teamId;

  const TeamDetailsPage({
    super.key,
    required this.teamId,
  });

  Future<void> _joinTeam(BuildContext context, WidgetRef ref, String userId) async {
    try {
      final repository = ref.read(teamRepositoryProvider);
      await repository.addMember(teamId, userId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы вступили в команду!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(teamDetailsProvider(teamId));
        ref.invalidate(teamMembersProvider(teamId));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveTeam(BuildContext context, WidgetRef ref, String userId) async {
    try {
      final repository = ref.read(teamRepositoryProvider);
      await repository.removeMember(teamId, userId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы покинули команду'),
            backgroundColor: Colors.orange,
          ),
        );
        ref.invalidate(teamDetailsProvider(teamId));
        ref.invalidate(teamMembersProvider(teamId));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTeam(BuildContext context, WidgetRef ref) async {
    // Показываем диалог подтверждения
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить команду?'),
        content: const Text(
          'Вы уверены, что хотите удалить команду? '
          'Это действие нельзя отменить. Все участники будут удалены из команды.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(teamRepositoryProvider);
      await repository.deleteTeam(teamId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Команда удалена'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Обновляем провайдеры
        ref.invalidate(allTeamsProvider);
        ref.invalidate(userTeamsProvider);
        
        // Возвращаемся на страницу команд
        context.go(AppRoutes.teams);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeMember(
    BuildContext context,
    WidgetRef ref,
    String memberId,
    String memberName,
  ) async {
    // Показываем диалог подтверждения
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить участника?'),
        content: Text(
          'Вы уверены, что хотите удалить $memberName из команды?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(teamRepositoryProvider);
      await repository.removeMember(teamId, memberId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$memberName удален из команды'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Обновляем провайдеры
        ref.invalidate(teamDetailsProvider(teamId));
        ref.invalidate(teamMembersProvider(teamId));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final teamAsyncValue = ref.watch(teamDetailsProvider(teamId));
    final membersAsyncValue = ref.watch(teamMembersProvider(teamId));

    return teamAsyncValue.when(
      data: (team) {
        if (team == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Детали команды'),
              centerTitle: true,
            ),
            body: const Center(child: Text('Команда не найдена')),
          );
        }

        final isMember = currentUser != null && team.isMember(currentUser.uid);
        final isCaptain = currentUser != null && team.isCaptain(currentUser.uid);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Детали команды'),
            centerTitle: true,
            actions: [
              if (isMember)
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    context.push(
                      AppRoutes.teamChat.replaceAll(':teamId', teamId),
                      extra: team,
                    );
                  },
                  tooltip: 'Чат команды',
                ),
              if (isCaptain)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.push(AppRoutes.editTeam.replaceAll(':teamId', teamId));
                  },
                  tooltip: 'Редактировать команду',
                ),
            ],
          ),
          body: teamAsyncValue.when(
            data: (team) {
              if (team == null) {
                return const Center(child: Text('Команда не найдена'));
              }

              final isMember = currentUser != null && team.isMember(currentUser.uid);
              final isCaptain = currentUser != null && team.isCaptain(currentUser.uid);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Header
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.group,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                team.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Game
                        Row(
                          children: [
                            const Icon(Icons.sports_esports, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              team.game,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Members Count
                        Row(
                          children: [
                            const Icon(Icons.people, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${team.memberIds.length}/${team.maxMembers} участников',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        
                        // Description
                        if (team.description != null && team.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Описание:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            team.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Members List header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Участники',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (isCaptain && !team.isFull)
                      TextButton.icon(
                        onPressed: () {
                          context.push(AppRoutes.invitePlayer.replaceAll(':teamId', teamId));
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Пригласить'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                
                membersAsyncValue.when(
                  data: (members) {
                    // Проверка и очистка "мертвых душ"
                    if (isCaptain && members.length != team.memberIds.length) {
                      Future.microtask(() {
                        ref.read(teamRepositoryProvider).cleanupTeamMembers(
                          team.id,
                          members.map((u) => u.uid).toList().cast<String>(),
                        ).then((_) {
                          ref.invalidate(teamDetailsProvider(team.id));
                        });
                      });
                    }

                    if (members.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('Нет участников'),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isMemberCaptain = team.isCaptain(member.id);
                        
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              backgroundImage: member.avatarUrl != null
                                  ? NetworkImage(member.avatarUrl!)
                                  : null,
                              child: member.avatarUrl == null
                                  ? Icon(
                                      Icons.person,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                            ),
                            title: Text(member.displayName),
                            subtitle: member.rank != null ? Text(member.rank!) : null,
                            trailing: isMemberCaptain
                                ? Chip(
                                    label: const Text('Капитан'),
                                    backgroundColor: Colors.amber.withOpacity(0.2),
                                  )
                                : (isCaptain
                                    ? IconButton(
                                        icon: const Icon(Icons.person_remove, color: Colors.red),
                                        onPressed: () => _removeMember(
                                          context,
                                          ref,
                                          member.id,
                                          member.displayName,
                                        ),
                                        tooltip: 'Удалить участника',
                                      )
                                    : null),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Ошибка: $error'),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                if (currentUser != null) ...[
                  if (!isMember && !team.isFull)
                    ElevatedButton.icon(
                      onPressed: () => _joinTeam(context, ref, currentUser.uid),
                      icon: const Icon(Icons.login),
                      label: const Text('Вступить в команду'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  
                  if (isMember && !isCaptain)
                    OutlinedButton.icon(
                      onPressed: () => _leaveTeam(context, ref, currentUser.uid),
                      icon: const Icon(Icons.logout),
                      label: const Text('Покинуть команду'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  
                  // Delete button for captain
                  if (isCaptain) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _deleteTeam(context, ref),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Удалить команду'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка загрузки: $error'),
        ),
      ),
    );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Детали команды'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Ошибка загрузки: $error'),
        ),
      ),
    );
  }
}
