import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/app/routes/app_routes.dart';
import 'package:team_for_gamers/features/auth/providers/auth_provider.dart';
import 'package:team_for_gamers/features/messages/providers/messages_provider.dart';
import 'package:team_for_gamers/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:team_for_gamers/features/profile/presentation/widgets/steam_profile_card.dart';
import 'package:team_for_gamers/features/profile/providers/user_provider.dart';

/// Страница просмотра публичного профиля другого пользователя
class PublicProfilePage extends ConsumerWidget {
  final String userId;

  const PublicProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль игрока'),
        centerTitle: true,
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Профиль не найден'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                // Display Name
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Bio
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'О себе',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.bio!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Rank
                ProfileInfoCard(
                  icon: Icons.emoji_events,
                  title: 'Ранг',
                  value: user.rank,
                  iconColor: Colors.amber,
                ),
                const SizedBox(height: 12),

                // Region
                ProfileInfoCard(
                  icon: Icons.public,
                  title: 'Регион',
                  value: user.region,
                  iconColor: Colors.blue,
                ),
                const SizedBox(height: 12),

                // Steam Profile
                if (user.steamId != null && user.steamId!.isNotEmpty) ...[
                  SteamProfileCard(steamId: user.steamId!),
                  const SizedBox(height: 16),
                ],

                // Favorite Games
                if (user.favoriteGames.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sports_esports,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Любимые игры',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.favoriteGames.map((game) {
                              return Chip(
                                label: Text(game),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка загрузки профиля: $error'),
        ),
      ),
      floatingActionButton: userAsyncValue.when(
        data: (user) {
          if (user == null) return null;
          
          final currentUser = ref.watch(currentUserProvider);
          // Не показываем кнопку для своего профиля
          if (currentUser == null || currentUser.uid == userId) {
            return null;
          }
          
          return FloatingActionButton.extended(
            onPressed: () async {
              try {
                // Создаем или получаем чат
                final messagesRepo = ref.read(messagesRepositoryProvider);
                final chat = await messagesRepo.getOrCreateChat(
                  currentUser.uid,
                  userId,
                );
                
                if (context.mounted) {
                  context.push(
                    AppRoutes.privateChat.replaceAll(':chatId', chat.id),
                    extra: chat,
                  );
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
            },
            icon: const Icon(Icons.message),
            label: const Text('Написать'),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}
