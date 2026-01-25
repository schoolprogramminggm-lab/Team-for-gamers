import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_for_gamers/features/messages/data/models/private_chat_model.dart';
import 'package:team_for_gamers/features/messages/data/models/private_message_model.dart';
import 'package:team_for_gamers/features/messages/data/repositories/messages_repository.dart';

/// Провайдер репозитория сообщений
final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepository();
});

/// Провайдер чатов пользователя (Stream)
final userChatsProvider =
    StreamProvider.family<List<PrivateChatModel>, String>((ref, userId) {
  final repository = ref.watch(messagesRepositoryProvider);
  return repository.getUserChatsStream(userId);
});

/// Провайдер сообщений конкретного чата (Stream)
final chatMessagesProvider =
    StreamProvider.family<List<PrivateMessageModel>, String>((ref, chatId) {
  final repository = ref.watch(messagesRepositoryProvider);
  return repository.getChatMessagesStream(chatId);
});

/// Провайдер общего количества непрочитанных сообщений
final totalUnreadMessagesProvider = FutureProvider.family<int, String>((ref, userId) async {
  final repository = ref.watch(messagesRepositoryProvider);
  return repository.getTotalUnreadCount(userId);
});
