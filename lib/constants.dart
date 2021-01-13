enum ConversationStatus {
  start,
  failure,
  success,
  quit,
}

const systemUser = '00000000-0000-0000-0000-000000000000';

const scp =
    'PROFILE:READ PROFILE:WRITE PHONE:READ PHONE:WRITE CONTACTS:READ CONTACTS:WRITE MESSAGES:READ MESSAGES:WRITE ASSETS:READ SNAPSHOTS:READ CIRCLES:READ CIRCLES:WRITE';

class ConversationCategory {
  static const String contact = 'CONTACT';

  static const String group = 'GROUP';
}

const acknowledgeMessageReceipts = 'ACKNOWLEDGE_MESSAGE_RECEIPTS';

class MessageStatus {
  static const String sending = 'SENDING';
  static const String sent = 'SENT';
  static const String delivered = 'DELIVERED';
  static const String read = 'READ';
  static const String failed = 'FAILED';
  static const String unknown = 'UNKNOWN';
}