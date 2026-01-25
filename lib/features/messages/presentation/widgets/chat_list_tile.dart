import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:team_for_gamers/features/messages/data/models/private_chat_model.dart';
import 'package:team_for_gamers/features/profile/providers/user_provider.dart';

/// Виджет для отображения чата в списке
class ChatListTile extends ConsumerWidget {
  final PrivateChatModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserId = chat.getOtherUserId(currentUserId);
    final userAsync = ref.watch(userProvider(otherUserId));
    final unreadCount = chat.getUnreadCount(currentUserId);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final timeText = chat.lastMessageTime != null
            ? _formatTime(chat.lastMessageTime!)
            : '';

        final isMyMessage = chat.lastMessageSenderId == currentUserId;
        final lastMessagePreview = chat.lastMessage != null
            ? (isMyMessage ? 'Вы: ${chat.lastMessage}' : chat.lastMessage!)
            : 'Нет сообщений';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            user.displayName,
            style: TextStyle(
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            lastMessagePreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unreadCount > 0 ? Colors.white : Colors.grey[400],
              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 12,
                  color: unreadCount > 0
                      ? Theme.of(context).primaryColor
                      : Colors.grey[500],
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: onTap,
        );
      },
      loading: () => const ListTile(
        leading: CircleAvatar(child: CircularProgressIndicator()),
        title: Text('Загрузка...'),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Вчера';
    } else if (now.difference(time).inDays < 7) {
      return DateFormat('EEEE', 'ru').format(time);
    } else {
      return DateFormat('dd.MM.yy').format(time);
    }
  }
}
