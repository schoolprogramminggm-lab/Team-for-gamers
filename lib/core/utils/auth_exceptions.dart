import 'package:firebase_auth/firebase_auth.dart';

/// Преобразует Firebase Auth ошибки в понятные сообщения на русском
String getAuthErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    // Ошибки входа
    case 'user-not-found':
      return 'Пользователь с таким email не найден';
    case 'wrong-password':
      return 'Неверный пароль';
    case 'invalid-credential':
      return 'Неверный email или пароль';
    case 'user-disabled':
      return 'Этот аккаунт был отключен';
    
    // Ошибки регистрации
    case 'email-already-in-use':
      return 'Этот email уже используется';
    case 'weak-password':
      return 'Пароль слишком простой (минимум 6 символов)';
    case 'invalid-email':
      return 'Некорректный формат email';
    
    // Общие ошибки
    case 'operation-not-allowed':
      return 'Операция не разрешена. Обратитесь к администратору';
    case 'too-many-requests':
      return 'Слишком много попыток. Попробуйте позже';
    case 'network-request-failed':
      return 'Ошибка сети. Проверьте подключение к интернету';
    
    // Ошибки сброса пароля
    case 'missing-email':
      return 'Введите email';
    
    default:
      return 'Произошла ошибка: ${e.message ?? e.code}';
  }
}
