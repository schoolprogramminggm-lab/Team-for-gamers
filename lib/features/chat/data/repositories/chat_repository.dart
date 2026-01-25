import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:team_for_gamers/features/chat/data/models/chat_message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Отправить сообщение в чат команды
  Future<void> sendMessage({
    required String teamId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      final messageId = _uuid.v4();
      final message = ChatMessageModel(
        id: messageId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('messages')
          .doc(messageId)
          .set(message.toJson());
    } catch (e) {
      throw Exception('Ошибка отправки сообщения: $e');
    }
  }

  /// Получить stream сообщений для команды
  Stream<List<ChatMessageModel>> getMessagesStream(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList();
    });
  }
}
