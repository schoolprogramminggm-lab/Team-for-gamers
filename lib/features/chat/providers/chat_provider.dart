import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_for_gamers/features/chat/data/models/chat_message_model.dart';
import 'package:team_for_gamers/features/chat/data/repositories/chat_repository.dart';

/// Провайдер репозитория чата
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Провайдер сообщений команды (Stream)
final teamMessagesProvider = StreamProvider.family<List<ChatMessageModel>, String>((ref, teamId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessagesStream(teamId);
});
