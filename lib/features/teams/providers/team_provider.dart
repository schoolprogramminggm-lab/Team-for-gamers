import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_for_gamers/features/profile/data/models/user_model.dart';
import 'package:team_for_gamers/features/profile/providers/user_provider.dart';
import 'package:team_for_gamers/features/teams/data/models/team_model.dart';
import 'package:team_for_gamers/features/teams/data/repositories/team_repository.dart';

/// Провайдер для TeamRepository
final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepository();
});

/// Провайдер для всех команд
final allTeamsProvider = FutureProvider<List<TeamModel>>((ref) async {
  final repository = ref.watch(teamRepositoryProvider);
  return await repository.getAllTeams();
});

/// Провайдер для команд пользователя
final userTeamsProvider = FutureProvider.family<List<TeamModel>, String>((ref, userId) async {
  final repository = ref.watch(teamRepositoryProvider);
  return await repository.getUserTeams(userId);
});

/// Провайдер для деталей команды
final teamDetailsProvider = FutureProvider.family<TeamModel?, String>((ref, teamId) async {
  final repository = ref.watch(teamRepositoryProvider);
  return await repository.getTeamById(teamId);
});

/// Провайдер для участников команды
final teamMembersProvider = FutureProvider.family<List<UserModel>, String>((ref, teamId) async {
  final teamRepository = ref.watch(teamRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  
  final team = await teamRepository.getTeamById(teamId);
  if (team == null) return [];

  final members = <UserModel>[];
  for (final memberId in team.memberIds) {
    final user = await userRepository.getUserById(memberId);
    if (user != null) {
      members.add(user);
    }
  }
  
  return members;
});

/// Провайдер для команд по игре
final teamsByGameProvider = FutureProvider.family<List<TeamModel>, String>((ref, game) async {
  final repository = ref.watch(teamRepositoryProvider);
  return await repository.getTeamsByGame(game);
});
