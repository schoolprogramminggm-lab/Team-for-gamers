import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Repository для работы с профилями пользователей в Firestore
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Название коллекции пользователей в Firestore
  static const String collectionName = 'users';

  /// Получить ссылку на коллекцию пользователей
  CollectionReference get _usersCollection => 
      _firestore.collection(collectionName);

  /// Создать новый профиль пользователя
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Ошибка при создании профиля: $e');
    }
  }

  /// Получить профиль пользователя по ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Ошибка при получении профиля: $e');
    }
  }

  /// Обновить профиль пользователя
  Future<void> updateUser(UserModel user) async {
    try {
      // Обновляем timestamp
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      
      await _usersCollection.doc(user.id).update(updatedUser.toJson());
    } catch (e) {
      throw Exception('Ошибка при обновлении профиля: $e');
    }
  }

  /// Удалить профиль пользователя
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Ошибка при удалении профиля: $e');
    }
  }

  /// Stream для отслеживания изменений профиля пользователя
  Stream<UserModel?> getUserStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserModel.fromFirestore(doc);
    });
  }

  /// Проверить, существует ли профиль пользователя
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Ошибка при проверке профиля: $e');
    }
  }

  /// Получить список пользователей по игре
  Future<List<UserModel>> getUsersByGame(String game) async {
    try {
      final querySnapshot = await _usersCollection
          .where('favoriteGames', arrayContains: game)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при поиске пользователей: $e');
    }
  }

  /// Получить список пользователей по региону
  Future<List<UserModel>> getUsersByRegion(String region) async {
    try {
      final querySnapshot = await _usersCollection
          .where('region', isEqualTo: region)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при поиске пользователей: $e');
    }
  }

  /// Поиск пользователей по имени (начинается с текста)
  Future<List<UserModel>> searchUsersByName(String query) async {
    try {
      final querySnapshot = await _usersCollection
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при поиске пользователей: $e');
    }
  }

  /// Получить недавно зарегистрированных пользователей
  Future<List<UserModel>> getRecentUsers({int limit = 10}) async {
    try {
      final querySnapshot = await _usersCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при получении новых пользователей: $e');
    }
  }

  /// Комплексный поиск пользователей с фильтрами
  Future<List<UserModel>> searchUsers({
    String? game,
    String? rank,
    String? region,
    String? nameQuery,
    int limit = 50,
  }) async {
    try {
      Query query = _usersCollection;

      // Применяем фильтры
      if (game != null && game.isNotEmpty) {
        query = query.where('favoriteGames', arrayContains: game);
      }

      if (rank != null && rank.isNotEmpty) {
        query = query.where('rank', isEqualTo: rank);
      }

      if (region != null && region.isNotEmpty) {
        query = query.where('region', isEqualTo: region);
      }

      // Поиск по имени (если нет других фильтров)
      if (nameQuery != null && nameQuery.isNotEmpty) {
        query = query
            .where('displayName', isGreaterThanOrEqualTo: nameQuery)
            .where('displayName', isLessThan: nameQuery + 'z');
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при поиске пользователей: $e');
    }
  }

  /// Получить всех пользователей (для начальной загрузки)
  Future<List<UserModel>> getAllUsers({int limit = 50}) async {
    try {
      final querySnapshot = await _usersCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при получении пользователей: $e');
    }
  }
}
