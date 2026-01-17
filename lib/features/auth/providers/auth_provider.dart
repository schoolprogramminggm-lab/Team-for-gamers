import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';

/// Провайдер для AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Провайдер для отслеживания состояния аутентификации (Stream)
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Провайдер для получения текущего пользователя (синхронно)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});
