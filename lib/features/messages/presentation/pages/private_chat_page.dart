import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_for_gamers/features/auth/providers/auth_provider.dart';
import 'package:team_for_gamers/features/messages/data/models/private_chat_model.dart';
import 'package:team_for_gamers/features/messages/providers/messages_provider.dart';
import 'package:team_for_gamers/core/widgets/message_bubble.dart';
import 'package:team_for_gamers/features/profile/providers/user_provider.dart';
import 'package:team_for_gamers/features/chat/data/models/chat_message_model.dart';

/// Страница личной переписки с пользователем
class PrivateChatPage extends ConsumerStatefulWidget {
  final PrivateChatModel chat;

  const PrivateChatPage({
    super.key,
    required this.chat,
  });

  @override
  ConsumerState<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends ConsumerState<PrivateChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Отмечаем сообщения как прочитанные при открытии
    _markAsRead();
  }

  void _markAsRead() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      ref
          .read(messagesRepositoryProvider)
          .markAsRead(widget.chat.id, currentUser.uid);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(messagesRepositoryProvider).sendMessage(
          chatId: widget.chat.id,
          senderId: user.uid,
          text: text,
        );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Необходима авторизация')),
      );
    }

    final otherUserId = widget.chat.getOtherUserId(currentUser.uid);
    final otherUserAsync = ref.watch(userProvider(otherUserId));
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chat.id));

    return Scaffold(
      appBar: AppBar(
        title: otherUserAsync.when(
          data: (user) => Text(user?.displayName ?? 'Пользователь'),
          loading: () => const Text('Загрузка...'),
          error: (_, __) => const Text('Ошибка'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Можно открыть профиль пользователя
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет сообщений. Начните общение!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser.uid;

                    // Конвертируем PrivateMessageModel в ChatMessageModel для MessageBubble
                    final chatMessage = ChatMessageModel(
                      id: message.id,
                      senderId: message.senderId,
                      senderName: '', // Не используется в личных чатах
                      text: message.text,
                      timestamp: message.timestamp,
                    );

                    return MessageBubble(
                      message: chatMessage,
                      isMe: isMe,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Ошибка: $e')),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black12,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Сообщение...',
                  filled: true,
                  fillColor: const Color(0xFF2A2A3D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
