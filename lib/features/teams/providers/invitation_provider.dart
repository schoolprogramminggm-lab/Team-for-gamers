import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_for_gamers/features/auth/providers/auth_provider.dart';
import 'package:team_for_gamers/features/teams/data/models/team_invitation_model.dart';
import 'package:team_for_gamers/features/teams/data/repositories/team_repository.dart';
import 'package:team_for_gamers/features/teams/providers/team_provider.dart';

/// Provider для stream приглашений пользователя
final userInvitationsStreamProvider = StreamProvider.family<List<TeamInvitationModel>, String>((ref, userId) {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.getUserInvitationsStream(userId);
});

/// Provider для текущих приглашений пользователя
final currentUserInvitationsProvider = StreamProvider<List<TeamInvitationModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }
  
  final repository = ref.watch(teamRepositoryProvider);
  return repository.getUserInvitationsStream(user.uid);
});

/// Provider для количества непрочитанных приглашений
final unreadInvitationsCountProvider = Provider<int>((ref) {
  final invitationsAsync = ref.watch(currentUserInvitationsProvider);
  
  return invitationsAsync.when(
    data: (invitations) => invitations
        .where((inv) => inv.status == InvitationStatus.pending)
        .length,
    loading: () => 0,
    error: (e, s) {
      print('UnreadInv Error: $e');
      return 0;
    },
  );
});

/// Provider для pending приглашений
final pendingInvitationsProvider = Provider<List<TeamInvitationModel>>((ref) {
  final invitationsAsync = ref.watch(currentUserInvitationsProvider);
  
  return invitationsAsync.when(
    data: (invitations) => invitations
        .where((inv) => inv.status.name == 'pending')
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider для истории приглашений (accepted/rejected)
final invitationHistoryProvider = Provider<List<TeamInvitationModel>>((ref) {
  final invitationsAsync = ref.watch(currentUserInvitationsProvider);
  
  return invitationsAsync.when(
    data: (invitations) => invitations
        .where((inv) => inv.status != InvitationStatus.pending)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
