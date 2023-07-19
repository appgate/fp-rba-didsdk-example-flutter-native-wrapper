part of didsdk;

enum _TransactionInfoAttributes {
  transactionID,
  subject,
  message,
  subjectNotification,
  messageNotification,
  urlToResponse,
  type,
  timeStamp,
  status,
  account,
  transactionOfflineCode,
}

class TransactionInfo {

  final String transactionID;
  final String subject;
  final String message;
  final String subjectNotification;
  final String messageNotification;
  final String urlToResponse;
  final String type;
  final int timeStamp;
  final String status;
  final Account account;
  final String transactionOfflineCode;

  TransactionInfo._(
      this.transactionID,
      this.subject,
      this.message,
      this.subjectNotification,
      this.messageNotification,
      this.urlToResponse,
      this.type,
      this.timeStamp,
      this.status,
      this.account,
      this.transactionOfflineCode,
  );

  factory TransactionInfo._getInstance(Map map) {
    return TransactionInfo._(
      _JsonMapper._getString(map, _TransactionInfoAttributes.transactionID.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.subject.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.message.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.subjectNotification.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.messageNotification.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.urlToResponse.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.type.name),
      _JsonMapper._getInt(map, _TransactionInfoAttributes.timeStamp.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.status.name),
      Account._getInstance(map[_TransactionInfoAttributes.account.name]),
      _JsonMapper._getString(map, _TransactionInfoAttributes.transactionOfflineCode.name),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _TransactionInfoAttributes.transactionID.name: transactionID,
      _TransactionInfoAttributes.subject.name: subject,
      _TransactionInfoAttributes.message.name: message,
      _TransactionInfoAttributes.subjectNotification.name: subjectNotification,
      _TransactionInfoAttributes.messageNotification.name: messageNotification,
      _TransactionInfoAttributes.urlToResponse.name: urlToResponse,
      _TransactionInfoAttributes.type.name: type,
      _TransactionInfoAttributes.timeStamp.name: timeStamp,
      _TransactionInfoAttributes.status.name: status,
      _TransactionInfoAttributes.account.name: account.toJson(),
      _TransactionInfoAttributes.transactionOfflineCode.name: transactionOfflineCode,
    };
  }
  static TransactionInfo fromJson(Map map) {
    return  TransactionInfo._(
      _JsonMapper._getString(map, _TransactionInfoAttributes.transactionID.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.subject.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.message.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.subjectNotification.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.messageNotification.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.urlToResponse.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.type.name),
      _JsonMapper._getInt(map, _TransactionInfoAttributes.timeStamp.name),
      _JsonMapper._getString(map, _TransactionInfoAttributes.status.name),
      Account._getInstance(map[_TransactionInfoAttributes.account.name]),
      _JsonMapper._getString(map, _TransactionInfoAttributes.transactionOfflineCode.name),
    );
  }
}
