import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель пользователя приложения Team for Gamers
class UserModel {
  final String id; // Firebase Auth UID
  String get uid => id; // Alias for id
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final List<String> favoriteGames;
  final String? rank; // Ранг игрока (например: "Золото", "Платина")
  final String? region; // Регион (например: "Европа", "Азия")
  final String? steamId; // Steam ID игрока
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.favoriteGames = const [],
    this.rank,
    this.region,
    this.steamId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создать UserModel из JSON (для чтения из Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      favoriteGames: (json['favoriteGames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rank: json['rank'] as String?,
      region: json['region'] as String?,
      steamId: json['steamId'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Создать UserModel из Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// Конвертировать UserModel в JSON (для записи в Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'favoriteGames': favoriteGames,
      'rank': rank,
      'region': region,
      'steamId': steamId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Создать копию UserModel с обновленными полями
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    List<String>? favoriteGames,
    String? rank,
    String? region,
    String? steamId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      favoriteGames: favoriteGames ?? this.favoriteGames,
      rank: rank ?? this.rank,
      region: region ?? this.region,
      steamId: steamId ?? this.steamId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Создать пустой профиль пользователя (при регистрации)
  factory UserModel.empty({
    required String id,
    required String email,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: id,
      email: email,
      displayName: email.split('@')[0], // Используем часть email как displayName
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.avatarUrl == avatarUrl &&
        other.bio == bio &&
        other.rank == rank &&
        other.region == region;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        avatarUrl.hashCode ^
        bio.hashCode ^
        rank.hashCode ^
        region.hashCode;
  }
}
