import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/team_model.dart';
import '../models/team_invitation_model.dart';

/// Repository для работы с командами в Firestore
class TeamRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  static const String teamsCollection = 'teams';
  static const String invitationsCollection = 'team_invitations';

  CollectionReference get _teamsCollection =>
      _firestore.collection(teamsCollection);
  CollectionReference get _invitationsCollection =>
      _firestore.collection(invitationsCollection);

  // ==================== CRUD команд ====================

  /// Создать новую команду
  Future<TeamModel> createTeam({
    required String name,
    required String game,
    required String captainId,
    String? description,
    int maxMembers = 5,
  }) async {
    try {
      final now = DateTime.now();
      final team = TeamModel(
        id: _uuid.v4(),
        name: name,
        description: description,
        game: game,
        captainId: captainId,
        memberIds: [captainId], // Капитан автоматически добавляется
        maxMembers: maxMembers,
        createdAt: now,
        updatedAt: now,
      );

      await _teamsCollection.doc(team.id).set(team.toJson());
      return team;
    } catch (e) {
      throw Exception('Ошибка при создании команды: $e');
    }
  }

  /// Получить команду по ID
  Future<TeamModel?> getTeamById(String teamId) async {
    try {
      final doc = await _teamsCollection.doc(teamId).get();
      if (!doc.exists) return null;
      return TeamModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Ошибка при получении команды: $e');
    }
  }

  /// Обновить команду
  Future<void> updateTeam(TeamModel team) async {
    try {
      final updatedTeam = team.copyWith(updatedAt: DateTime.now());
      await _teamsCollection.doc(team.id).update(updatedTeam.toJson());
    } catch (e) {
      throw Exception('Ошибка при обновлении команды: $e');
    }
  }

  /// Удалить команду
  Future<void> deleteTeam(String teamId) async {
    try {
      await _teamsCollection.doc(teamId).delete();
    } catch (e) {
      throw Exception('Ошибка при удалении команды: $e');
    }
  }

  // ==================== Управление участниками ====================

  /// Добавить участника в команду
  Future<void> addMember(String teamId, String userId) async {
    try {
      final team = await getTeamById(teamId);
      if (team == null) throw Exception('Команда не найдена');
      
      if (team.isFull) throw Exception('Команда заполнена');
      if (team.isMember(userId)) throw Exception('Пользователь уже в команде');

      final updatedMemberIds = [...team.memberIds, userId];
      await _teamsCollection.doc(teamId).update({
        'memberIds': updatedMemberIds,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Ошибка при добавлении участника: $e');
    }
  }

  /// Удалить участника из команды
  Future<void> removeMember(String teamId, String userId) async {
    try {
      final team = await getTeamById(teamId);
      if (team == null) throw Exception('Команда не найдена');
      
      if (team.captainId == userId) {
        throw Exception('Капитан не может покинуть команду');
      }

      final updatedMemberIds = team.memberIds.where((id) => id != userId).toList();
      await _teamsCollection.doc(teamId).update({
        'memberIds': updatedMemberIds,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Ошибка при удалении участника: $e');
    }
  }

  /// Очистить список участников (удалить несуществующих)
  Future<void> cleanupTeamMembers(String teamId, List<String> validMemberIds) async {
    try {
      await _teamsCollection.doc(teamId).update({
        'memberIds': validMemberIds,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Ошибка при очистке команды: $e');
    }
  }

  // ==================== Поиск команд ====================

  /// Получить все команды
  Future<List<TeamModel>> getAllTeams({int limit = 50}) async {
    try {
      final querySnapshot = await _teamsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => TeamModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при получении команд: $e');
    }
  }

  /// Получить команды по игре
  Future<List<TeamModel>> getTeamsByGame(String game) async {
    try {
      final querySnapshot = await _teamsCollection
          .where('game', isEqualTo: game)
          .get();

      // Сортируем на клиенте
      final teams = querySnapshot.docs
          .map((doc) => TeamModel.fromFirestore(doc))
          .toList();
      
      teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return teams;
    } catch (e) {
      throw Exception('Ошибка при поиске команд: $e');
    }
  }

  /// Получить команды пользователя
  Future<List<TeamModel>> getUserTeams(String userId) async {
    try {
      final querySnapshot = await _teamsCollection
          .where('memberIds', arrayContains: userId)
          .get();

      // Сортируем на клиенте
      final teams = querySnapshot.docs
          .map((doc) => TeamModel.fromFirestore(doc))
          .toList();
      
      teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return teams;
    } catch (e) {
      throw Exception('Ошибка при получении команд пользователя: $e');
    }
  }

  // ==================== Приглашения ====================

  /// Отправить приглашение в команду
  Future<void> sendInvitation({
    required String teamId,
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      final invitation = TeamInvitationModel(
        id: _uuid.v4(),
        teamId: teamId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        createdAt: DateTime.now(),
      );

      await _invitationsCollection.doc(invitation.id).set(invitation.toJson());
    } catch (e) {
      throw Exception('Ошибка при отправке приглашения: $e');
    }
  }

  /// Принять приглашение
  Future<void> acceptInvitation(String invitationId) async {
    try {
      final doc = await _invitationsCollection.doc(invitationId).get();
      if (!doc.exists) throw Exception('Приглашение не найдено');

      final invitation = TeamInvitationModel.fromFirestore(doc);
      
      // Добавляем пользователя в команду
      await addMember(invitation.teamId, invitation.toUserId);
      
      // Обновляем статус приглашения
      await _invitationsCollection.doc(invitationId).update({
        'status': InvitationStatus.accepted.toJson(),
      });
    } catch (e) {
      throw Exception('Ошибка при принятии приглашения: $e');
    }
  }

  /// Отклонить приглашение
  Future<void> rejectInvitation(String invitationId) async {
    try {
      await _invitationsCollection.doc(invitationId).update({
        'status': InvitationStatus.rejected.toJson(),
      });
    } catch (e) {
      throw Exception('Ошибка при отклонении приглашения: $e');
    }
  }

  /// Получить приглашения пользователя
  Future<List<TeamInvitationModel>> getUserInvitations(String userId) async {
    try {
      final querySnapshot = await _invitationsCollection
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: InvitationStatus.pending.toJson())
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TeamInvitationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при получении приглашений: $e');
    }
  }

  /// Stream приглашений пользователя
  Stream<List<TeamInvitationModel>> getUserInvitationsStream(String userId) {
    return _invitationsCollection
        .where('toUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final invitations = snapshot.docs
          .map((doc) => TeamInvitationModel.fromFirestore(doc))
          .toList();
      
      // Сортировка на клиенте
      invitations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return invitations;
    });
  }



  /// Проверить наличие активного приглашения
  Future<bool> hasActiveInvitation(String teamId, String userId) async {
    try {
      final querySnapshot = await _invitationsCollection
          .where('teamId', isEqualTo: teamId)
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: InvitationStatus.pending.toJson())
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
