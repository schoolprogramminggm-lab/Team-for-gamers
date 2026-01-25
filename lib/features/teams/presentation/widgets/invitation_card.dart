import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/app/routes/app_routes.dart';
import 'package:team_for_gamers/features/teams/data/models/team_invitation_model.dart';
import 'package:team_for_gamers/features/teams/providers/team_provider.dart';
import 'package:team_for_gamers/features/teams/providers/invitation_provider.dart';
import 'package:intl/intl.dart';

/// Карточка приглашения в команду
class InvitationCard extends ConsumerWidget {
  final TeamInvitationModel invitation;

  const InvitationCard({
    super.key,
    required this.invitation,
  });

  Future<void> _acceptInvitation(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(teamRepositoryProvider);
      await repository.acceptInvitation(invitation.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы вступили в команду!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Обновляем провайдеры
        ref.invalidate(currentUserInvitationsProvider);
        ref.invalidate(userTeamsProvider);
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

  Future<void> _rejectInvitation(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(teamRepositoryProvider);
      await repository.rejectInvitation(invitation.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Приглашение отклонено'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Обновляем провайдер
        ref.invalidate(currentUserInvitationsProvider);
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
    final teamAsync = ref.watch(teamDetailsProvider(invitation.teamId));
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: teamAsync.when(
        data: (team) {
          if (team == null) {
            return const ListTile(
              title: Text('Команда не найдена'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Info
                Row(
                  children: [
                    Icon(
                      Icons.group,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.sports_esports,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                team.game,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Invitation Date
                Text(
                  'Приглашение от ${dateFormat.format(invitation.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                if (invitation.status == InvitationStatus.pending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptInvitation(context, ref),
                          icon: const Icon(Icons.check),
                          label: const Text('Принять'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectInvitation(context, ref),
                          icon: const Icon(Icons.close),
                          label: const Text('Отклонить'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.push(AppRoutes.teamDetails.replaceAll(':teamId', team.id));
                    },
                    child: const Text('Посмотреть команду'),
                  ),
                ] else ...[
                  // Status badge
                  Chip(
                    label: Text(
                      invitation.status == InvitationStatus.accepted
                          ? 'Принято'
                          : 'Отклонено',
                    ),
                    backgroundColor: invitation.status == InvitationStatus.accepted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => ListTile(
          title: const Text('Ошибка загрузки'),
          subtitle: Text(error.toString()),
        ),
      ),
    );
  }
}
