import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/features/auth/providers/auth_provider.dart';
import 'package:team_for_gamers/features/profile/data/models/user_model.dart';
import 'package:team_for_gamers/features/profile/providers/user_provider.dart';
import 'package:team_for_gamers/features/teams/providers/team_provider.dart';
import 'package:team_for_gamers/core/widgets/custom_text_field.dart';

/// Страница поиска и приглашения игроков
class InvitePlayerPage extends ConsumerStatefulWidget {
  final String teamId;

  const InvitePlayerPage({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<InvitePlayerPage> createState() => _InvitePlayerPageState();
}

class _InvitePlayerPageState extends ConsumerState<InvitePlayerPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _invitePlayer(String userId, String userName) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    // Проверяем, не является ли игрок уже участником
    final teamAsync = ref.read(teamDetailsProvider(widget.teamId));
    final team = teamAsync.value;
    
    if (team != null && team.isMember(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$userName уже в команде')),
      );
      return;
    }
    
    // Проверяем, есть ли уже активное приглашение
    final repository = ref.read(teamRepositoryProvider);
    final hasInvitation = await repository.hasActiveInvitation(widget.teamId, userId);
    
    if (hasInvitation) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Приглашение для $userName уже отправлено')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await repository.sendInvitation(
        teamId: widget.teamId,
        fromUserId: currentUser.uid,
        toUserId: userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Приглашение отправлено $userName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // В реальном приложении здесь был бы поиск пользователей через репозиторий
    // Для упрощения используем searchUsersProvider если он есть, или создадим поиск
    final searchResultsAsync = ref.watch(searchUsersProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Пригласить игрока'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              labelText: 'Поиск игрока',
              hintText: 'Введите имя игрока',
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty 
                ? const Center(
                    child: Text(
                      'Введите имя для поиска',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : searchResultsAsync.when(
                    data: (users) {
                      if (users.isEmpty) {
                        return const Center(child: Text('Игроки не найдены'));
                      }
                      
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isCurrentUser = user.uid == ref.read(currentUserProvider)?.uid;
                          
                          if (isCurrentUser) return const SizedBox.shrink();

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.avatarUrl != null 
                                  ? NetworkImage(user.avatarUrl!) 
                                  : null,
                              child: user.avatarUrl == null 
                                  ? const Icon(Icons.person) 
                                  : null,
                            ),
                            title: Text(user.displayName),
                            subtitle: user.rank != null ? Text(user.rank!) : null,
                            trailing: ElevatedButton(
                              onPressed: _isLoading 
                                  ? null 
                                  : () => _invitePlayer(user.uid, user.displayName),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Пригласить'),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Ошибка: $e')),
                  ),
          ),
        ],
      ),
    );
  }
}
