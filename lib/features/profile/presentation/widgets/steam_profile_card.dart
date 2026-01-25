import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_for_gamers/core/services/steam_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SteamProfileCard extends ConsumerStatefulWidget {
  final String steamId;

  const SteamProfileCard({
    super.key,
    required this.steamId,
  });

  @override
  ConsumerState<SteamProfileCard> createState() => _SteamProfileCardState();
}

class _SteamProfileCardState extends ConsumerState<SteamProfileCard> {
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>>? _gamesData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSteamData();
  }

  Future<void> _loadSteamData() async {
    try {
      final steamService = ref.read(steamServiceProvider);
      
      // Параллельная загрузка данных
      final results = await Future.wait([
        steamService.getPlayerSummary(widget.steamId),
        steamService.getOwnedGames(widget.steamId),
      ]);

      if (mounted) {
        setState(() {
          _profileData = results[0] as Map<String, dynamic>?;
          _gamesData = results[1] as List<Map<String, dynamic>>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _openSteamProfile() async {
    if (_profileData == null) return;
    
    final url = Uri.parse(_profileData!['profileurl']);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_hasError || _profileData == null) {
      return Card(
        color: Colors.red[50],
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Expanded(child: Text('Не удалось загрузить данные Steam')),
            ],
          ),
        ),
      );
    }

    final avatarUrl = _profileData!['avatarfull'];
    final personaName = _profileData!['personaname'];
    final status = _getStatus(_profileData!['personastate']);
    final gameExtraInfo = _profileData!['gameextrainfo']; // Если в игре

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF171A21), // Steam Dark Blue
            child: Row(
              children: [
                const Icon(Icons.videogame_asset, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Steam Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (gameExtraInfo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'В игре: $gameExtraInfo',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                    const SizedBox(width: 16),
                    
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            personaName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: status.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                status.text,
                                style: TextStyle(
                                  color: status.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Button
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: _openSteamProfile,
                      tooltip: 'Открыть профиль',
                    ),
                  ],
                ),
                
                if (_gamesData != null && _gamesData!.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Топ игр по времени:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _gamesData!.take(5).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final game = _gamesData![index];
                        return Chip(
                          label: Text(
                            '${(game['playtime_forever'] / 60).toStringAsFixed(1)} ч',
                            style: const TextStyle(fontSize: 10),
                          ),
                          avatar: Image.network(
                            'http://media.steampowered.com/steamcommunity/public/images/apps/${game['appid']}/${game['img_icon_url']}.jpg',
                            errorBuilder: (_, __, ___) => const Icon(Icons.gamepad, size: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({String text, Color color}) _getStatus(int? state) {
    switch (state) {
      case 0: return (text: 'Offline', color: Colors.grey);
      case 1: return (text: 'Online', color: Colors.blue);
      case 2: return (text: 'Busy', color: Colors.red);
      case 3: return (text: 'Away', color: Colors.amber);
      case 4: return (text: 'Snooze', color: Colors.amber);
      case 5: return (text: 'Looking to Trade', color: Colors.green);
      case 6: return (text: 'Looking to Play', color: Colors.green);
      default: return (text: 'Unknown', color: Colors.grey);
    }
  }
}
