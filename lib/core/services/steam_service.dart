import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final steamServiceProvider = Provider((ref) => SteamService());

class SteamService {
  // TODO: Попросить пользователя вставить сюда свой ключ или вынести в .env
  // https://steamcommunity.com/dev/apikey
  static const String _apiKey = 'YOUR_STEAM_API_KEY'; 
  
  static const String _baseUrl = 'https://api.steampowered.com';

  /// Получить информацию об игроке (avatar, nickname, status)
  /// https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerSummaries_.28v0002.29
  Future<Map<String, dynamic>?> getPlayerSummary(String steamId) async {
    if (_apiKey == 'YOUR_STEAM_API_KEY') {
       print('⚠️ STEAM_API_KEY не установлен! Вставьте ключ в steam_service.dart');
       return null;
    }

    try {
      final url = Uri.parse(
          '$_baseUrl/ISteamUser/GetPlayerSummaries/v0002/?key=$_apiKey&steamids=$steamId');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final players = data['response']['players'] as List;
        
        if (players.isNotEmpty) {
          return players.first as Map<String, dynamic>;
        }
      } else {
        print('Steam API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Steam Service Error: $e');
    }
    return null;
  }

  /// Получить список игр пользователя
  /// https://developer.valvesoftware.com/wiki/Steam_Web_API#GetOwnedGames_.28v0001.29
  Future<List<Map<String, dynamic>>> getOwnedGames(String steamId) async {
    if (_apiKey == 'YOUR_STEAM_API_KEY') return [];

    try {
      final url = Uri.parse(
          '$_baseUrl/IPlayerService/GetOwnedGames/v0001/?key=$_apiKey&steamid=$steamId&include_appinfo=true&format=json');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final games = data['response']['games'] as List?;
        
        if (games != null) {
          // Сортируем по времени игры (последние 2 недели или всего)
          games.sort((a, b) {
             final playtimeA = (a['playtime_2weeks'] ?? 0) as int;
             final playtimeB = (b['playtime_2weeks'] ?? 0) as int;
             if (playtimeA != playtimeB) {
               return playtimeB.compareTo(playtimeA);
             }
             return ((b['playtime_forever'] ?? 0) as int).compareTo((a['playtime_forever'] ?? 0) as int);
          });
          
          return games.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('Steam Games Error: $e');
    }
    return [];
  }
}
