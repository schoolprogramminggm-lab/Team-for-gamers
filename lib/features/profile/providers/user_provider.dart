import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

/// Провайдер для UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Провайдер для получения профиля пользователя по ID (Stream)
final userStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserStream(userId);
});

/// Провайдер для получения профиля пользователя по ID (Future)
final userProvider = FutureProvider.family<UserModel?, String>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserById(userId);
});

/// Провайдер для списка недавно зарегистрированных пользователей
final recentUsersProvider = FutureProvider<List<UserModel>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getRecentUsers();
});

/// Провайдер для поиска пользователей по имени
final searchUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repository = ref.watch(userRepositoryProvider);
  return repository.searchUsers(nameQuery: query);
});
