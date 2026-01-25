import 'package:cloud_firestore/cloud_firestore.dart';

/// Статус приглашения в команду
enum InvitationStatus {
  pending,
  accepted,
  rejected;

  String toJson() => name;

  static InvitationStatus fromJson(String value) {
    return InvitationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}

/// Модель приглашения в команду
class TeamInvitationModel {
  final String id;
  final String teamId;
  final String fromUserId; // Кто пригласил (обычно капитан)
  final String toUserId; // Кого пригласили
  final InvitationStatus status;
  final DateTime createdAt;

  TeamInvitationModel({
    required this.id,
    required this.teamId,
    required this.fromUserId,
    required this.toUserId,
    this.status = InvitationStatus.pending,
    required this.createdAt,
  });

  /// Создать из JSON
  factory TeamInvitationModel.fromJson(Map<String, dynamic> json) {
    return TeamInvitationModel(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      status: InvitationStatus.fromJson(json['status'] as String),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Создать из Firestore DocumentSnapshot
  factory TeamInvitationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamInvitationModel.fromJson(data);
  }

  /// Конвертировать в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Создать копию с обновленным статусом
  TeamInvitationModel copyWith({
    InvitationStatus? status,
  }) {
    return TeamInvitationModel(
      id: id,
      teamId: teamId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'TeamInvitationModel(id: $id, teamId: $teamId, status: $status)';
  }
}
