import 'dart:async';

import 'package:flutter_app/db/mixin_database.dart';
import 'package:moor/moor.dart';

part 'conversations_dao.g.dart';

@UseDao(tables: [Conversations])
class ConversationsDao extends DatabaseAccessor<MixinDatabase>
    with _$ConversationsDaoMixin {
  ConversationsDao(MixinDatabase db) : super(db);

  Future<int> insert(Conversation conversation) async {
    final result =
        await into(db.conversations).insertOnConflictUpdate(conversation);
    return result;
  }

  Future<Conversation> getConversationById(String conversationId) {
    final query = select(db.conversations)
      ..where((tbl) => tbl.conversationId.equals(conversationId));
    return query.getSingle();
  }

  Selectable<ConversationItem> conversations(
    DateTime oldestCreatedAt,
    int limit, [
    List<String> loadedConversationId = const [],
  ]) =>
      db.conversationItems(loadedConversationId, oldestCreatedAt, limit);

  Selectable<ConversationItem> contactConversations(
    DateTime oldestCreatedAt,
    int limit, [
    List<String> loadedConversationId = const [],
  ]) =>
      db.contactConversations(loadedConversationId, oldestCreatedAt, limit);

  Selectable<ConversationItem> strangerConversations(
    DateTime oldestCreatedAt,
    int limit, [
    List<String> loadedConversationId = const [],
  ]) =>
      db.strangerConversations(loadedConversationId, oldestCreatedAt, limit);

  Selectable<ConversationItem> groupConversations(
    DateTime oldestCreatedAt,
    int limit, [
    List<String> loadedConversationId = const [],
  ]) =>
      db.groupConversations(loadedConversationId, oldestCreatedAt, limit);

  Selectable<ConversationItem> botConversations(
    DateTime oldestCreatedAt,
    int limit, [
    List<String> loadedConversationId = const [],
  ]) =>
      db.botConversations(loadedConversationId, oldestCreatedAt, limit);

  Future<int> updateLastMessageId(String conversationId, String messageId) =>
      (update(db.conversations)
            ..where((tbl) => tbl.conversationId.equals(conversationId)))
          .write(ConversationsCompanion(lastMessageId: Value(messageId)));
}
