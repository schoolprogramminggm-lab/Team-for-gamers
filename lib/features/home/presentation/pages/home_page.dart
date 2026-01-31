import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/app/routes/app_routes.dart';
import 'package:team_for_gamers/app/theme/app_colors.dart';
import 'package:team_for_gamers/core/widgets/glassmorphic_card.dart';
import 'package:team_for_gamers/core/widgets/gradient_button.dart';
import 'package:team_for_gamers/core/widgets/neon_search_bar.dart';
import 'package:team_for_gamers/features/auth/providers/auth_provider.dart';
import 'package:team_for_gamers/features/teams/providers/invitation_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  String _selectedGame = 'Все игры';

  final List<Map<String, dynamic>> _mockPlayers = [
    {
      'name': 'ShadowReaper',
      'rank': 'Radiant',
      'role': 'Carry',
      'game': 'Dota 2',
      'rankColor': Color(0xFFFF4655),
    },
    {
      'name': 'NovaStrike',
      'rank': 'Immortal',
      'role': 'Support',
      'game': 'CS2',
      'rankColor': Color(0xFF9d4edd),
    },
    {
      'name': 'PixelWarrior',
      'rank': 'Legend',
      'role': 'Midlaner',
      'game': 'Dota 2',
      'rankColor': Color(0xFFF39C12),
    },
    {
      'name': 'GlitchMaster',
      'rank': 'Pro',
      'role': 'Offlaner',
      'game': 'Valorant',
      'rankColor': Color(0xFF00d9ff),
    },
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        context.push(AppRoutes.teams);
        break;
      case 2:
        context.push(AppRoutes.chats);
        break;
      case 3:
        context.push(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadInvitationsCountProvider);
    final userName = user?.email?.split('@').first ?? 'ProPlayer_99';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with welcome and icons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Добро пожаловать,',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Invitations badge
                      IconButton(
                        icon: Badge(
                          label: Text('$unreadCount'),
                          isLabelVisible: unreadCount > 0,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.notifications_outlined, color: Colors.white),
                        ),
                        onPressed: () {
                          context.push(AppRoutes.invitations);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () {
                          context.push(AppRoutes.profile);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: NeonSearchBar(
                hintText: 'Поиск игроков, команд или игр...',
              ),
            ),
            
            const SizedBox(height: 16),

            // Game filters
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildGameChip('Все игры', null),
                  const SizedBox(width: 8),
                  _buildGameChip('Dota 2', AppColors.dota2),
                  const SizedBox(width: 8),
                  _buildGameChip('CS2', AppColors.cs2),
                  const SizedBox(width: 8),
                  _buildGameChip('Valorant', AppColors.valorant),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recommended teammates header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Рекомендуемые тиммейты',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(AppRoutes.search);
                    },
                    child: Text(
                      'Смотреть все',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Player cards grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _mockPlayers.length,
                itemBuilder: (context, index) {
                  final player = _mockPlayers[index];
                  return _buildPlayerCard(player);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.teams);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Команды',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Сообщения',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _buildGameChip(String game, Color? color) {
    final isSelected = _selectedGame == game;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGame = game;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              game,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with gradient background
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientPurple.withOpacity(0.3),
                  AppColors.gradientCyan.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[800],
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Player name with rank
          Text(
            '${player['name']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Rank
          Text(
            player['rank'],
            style: TextStyle(
              color: player['rankColor'],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Role
          Row(
            children: [
              Icon(
                Icons.sports_esports,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  player['role'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Invite button
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: 'Позвать',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Приглашение отправлено ${player['name']}!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              height: 36,
            ),
          ),
        ],
      ),
    );
  }
}
