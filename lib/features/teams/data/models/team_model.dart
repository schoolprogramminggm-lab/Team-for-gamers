import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель команды
class TeamModel {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String game; // Основная игра команды
  final String captainId; // ID капитана
  final List<String> memberIds; // ID всех участников (включая капитана)
  final int maxMembers; // Максимум участников
  final DateTime createdAt;
  final DateTime updatedAt;

  TeamModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    required this.game,
    required this.captainId,
    required this.memberIds,
    this.maxMembers = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создать TeamModel из JSON
  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      game: json['game'] as String,
      captainId: json['captainId'] as String,
      memberIds: (json['memberIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      maxMembers: json['maxMembers'] as int? ?? 5,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Создать TeamModel из Firestore DocumentSnapshot
  factory TeamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamModel.fromJson(data);
  }

  /// Конвертировать в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'game': game,
      'captainId': captainId,
      'memberIds': memberIds,
      'maxMembers': maxMembers,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Создать копию с обновленными полями
  TeamModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? game,
    String? captainId,
    List<String>? memberIds,
    int? maxMembers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      game: game ?? this.game,
      captainId: captainId ?? this.captainId,
      memberIds: memberIds ?? this.memberIds,
      maxMembers: maxMembers ?? this.maxMembers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Проверить, заполнена ли команда
  bool get isFull => memberIds.length >= maxMembers;

  /// Проверить, является ли пользователь капитаном
  bool isCaptain(String userId) => captainId == userId;

  /// Проверить, является ли пользователь участником
  bool isMember(String userId) => memberIds.contains(userId);

  @override
  String toString() {
    return 'TeamModel(id: $id, name: $name, game: $game, members: ${memberIds.length}/$maxMembers)';
  }
}
