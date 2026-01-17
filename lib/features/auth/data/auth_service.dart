import 'package:firebase_auth/firebase_auth.dart';

/// Сервис для работы с Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream состояния аутентификации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Текущий пользователь
  User? get currentUser => _auth.currentUser;

  /// Регистрация нового пользователя
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Неизвестная ошибка при регистрации: $e');
    }
  }

  /// Вход существующего пользователя
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Неизвестная ошибка при входе: $e');
    }
  }

  /// Выход из системы
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Ошибка при выходе: $e');
    }
  }

  /// Сброс пароля
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Ошибка при сбросе пароля: $e');
    }
  }
}
