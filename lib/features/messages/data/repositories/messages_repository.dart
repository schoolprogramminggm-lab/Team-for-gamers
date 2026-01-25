import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:team_for_gamers/features/messages/data/models/private_chat_model.dart';
import 'package:team_for_gamers/features/messages/data/models/private_message_model.dart';

class MessagesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _chatsCollection => _firestore.collection('chats');

  /// Получить или создать чат между двумя пользователями
  Future<PrivateChatModel> getOrCreateChat(
    String userId1,
    String userId2,
  ) async {
    try {
      final chatId = PrivateChatModel.generateChatId(userId1, userId2);
      final chatDoc = await _chatsCollection.doc(chatId).get();

      if (chatDoc.exists) {
        return PrivateChatModel.fromFirestore(chatDoc);
      }

      // Создаем новый чат
      final now = DateTime.now();
      final newChat = PrivateChatModel(
        id: chatId,
        participantIds: [userId1, userId2],
        unreadCount: {userId1: 0, userId2: 0},
        createdAt: now,
        updatedAt: now,
      );

      await _chatsCollection.doc(chatId).set(newChat.toJson());
      return newChat;
    } catch (e) {
      throw Exception('Ошибка создания чата: $e');
    }
  }

  /// Получить stream чатов пользователя
  Stream<List<PrivateChatModel>> getUserChatsStream(String userId) {
    return _chatsCollection
        .where('participantIds', arrayContains: userId)
        // .orderBy('updatedAt', descending: true) // Убрали сортировку, чтобы не создавать индекс
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs
          .map((doc) => PrivateChatModel.fromFirestore(doc))
          .toList();
      
      // Сортировка на клиенте
      chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return chats;
    });
  }

  /// Получить stream сообщений чата
  Stream<List<PrivateMessageModel>> getChatMessagesStream(String chatId) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrivateMessageModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Отправить сообщение
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      final messageId = _uuid.v4();
      final now = DateTime.now();

      final message = PrivateMessageModel(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        text: text,
        timestamp: now,
        isRead: false,
      );

      // Получаем данные чата для обновления
      final chatDoc = await _chatsCollection.doc(chatId).get();
      if (!chatDoc.exists) {
        throw Exception('Чат не найден');
      }

      final chat = PrivateChatModel.fromFirestore(chatDoc);
      final receiverId = chat.getOtherUserId(senderId);

      // Добавляем сообщение
      await _chatsCollection
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(message.toJson());

      // Обновляем метаданные чата
      final newUnreadCount = Map<String, int>.from(chat.unreadCount);
      newUnreadCount[receiverId] = (newUnreadCount[receiverId] ?? 0) + 1;

      await _chatsCollection.doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': Timestamp.fromDate(now),
        'lastMessageSenderId': senderId,
        'unreadCount': newUnreadCount,
        'updatedAt': Timestamp.fromDate(now),
      });
    } catch (e) {
      throw Exception('Ошибка отправки сообщения: $e');
    }
  }

  /// Отметить сообщения как прочитанные
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'unreadCount.$userId': 0,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Ошибка отметки прочитанных: $e');
    }
  }

  /// Получить общее количество непрочитанных сообщений
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      final chatsSnapshot = await _chatsCollection
          .where('participantIds', arrayContains: userId)
          .get();

      int total = 0;
      for (var doc in chatsSnapshot.docs) {
        final chat = PrivateChatModel.fromFirestore(doc);
        total += chat.getUnreadCount(userId);
      }
      return total;
    } catch (e) {
      return 0;
    }
  }
}
