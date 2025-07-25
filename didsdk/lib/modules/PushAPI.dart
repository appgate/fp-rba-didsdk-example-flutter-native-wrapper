part of didsdk;

class _PushAPIConstants {
  static const push_transaction = "push_transaction";
  static const push_alert = "push_alert";
  static const server_response = "server_response";
  static const push_alert_received = "PushAlertReceived";
  static const push_transaction_received = "PushTransactionReceived";
  static const transaction = "transaction";
  static const type_transaction = "type_transaction";
  static const newToken = "newToken";
  static const provider = "provider";
  static const remoteMessage = "remoteMessage";
  static const code = "code";
  static const success = "1020";
}

class PushAPI {
  MethodChannel channel;
  StreamController<TransactionInfo>? pushTransactionOpenStream;
  StreamController<TransactionInfo>? pushAlertOpenStream;
  StreamController<TransactionInfo>? pushTransactionReceivedStream;
  StreamController<TransactionInfo>? pushAlertReceivedStream;
  StreamController<String>? pushTransactionServerResponseStream;

  PushAPI(this.channel) {
    channel.setMethodCallHandler((call) async {
      final arguments = call.arguments;
      switch (call.method) {
        case _PushAPIConstants.push_transaction:
          var value = arguments[_PushAPIConstants.transaction];
          if (value is String) {
            pushTransactionOpenStream?.add(
                TransactionInfo._getInstance(json.decode(value)));
          }
          break;
        case _PushAPIConstants.push_alert:
          var value = arguments[_PushAPIConstants.transaction];
          if (value is String) {
            pushAlertOpenStream?.add(
                TransactionInfo._getInstance(json.decode(value)));
          }
          break;
        case _PushAPIConstants.server_response:
          pushTransactionServerResponseStream?.add(
              arguments[_PushAPIConstants.code] ?? "");
          break;
        case _PushAPIConstants.push_alert_received:
          var value = arguments[_PushAPIConstants.transaction];
          if (value is String) {
            pushAlertReceivedStream?.add(
                TransactionInfo._getInstance(json.decode(value)));
          }
          break;
        case _PushAPIConstants.push_transaction_received:
          var value = arguments[_PushAPIConstants.transaction];
          if (value is String) {
            pushTransactionReceivedStream?.add(
                TransactionInfo._getInstance(json.decode(value)));
          }
          break;
      }
    });
  }

  Future setPushTransactionOpenListener() {
    pushTransactionOpenStream = StreamController();
    Completer completer = Completer<Stream>();
    Future.delayed(const Duration(milliseconds: 1), () {
      channel.invokeListMethod(
          MethodNames.setPushTransactionOpenListener.name, {})
          .then((data) {
        Future.delayed(
            const Duration(seconds: 1), () => {
        completer.complete(pushTransactionOpenStream!.stream)
        });
      })
          .catchError((error) {
        completer.completeError(AppgateSDKError.toError(error));
      });
    });
    return completer.future;
  }

  Future setPushAlertOpenListener() {
    pushAlertOpenStream = StreamController();
    Completer completer = Completer<Stream>();
    Future.delayed(const Duration(milliseconds: 1), () {
      channel.invokeListMethod(MethodNames.setPushAlertOpenListener.name, {})
          .then((_) {
        Future.delayed(
            const Duration(seconds: 1), () => {
        completer.complete(pushAlertOpenStream!.stream)
        });
      }).catchError((error) {
        completer.completeError(AppgateSDKError.toError(error));
      });
    });
    return completer.future;
  }

  Future<void> confirmPushTransactionAction(TransactionInfo transaction) {
    return channel.invokeListMethod(
        MethodNames.confirmPushTransactionAction.name, {
      _QRAuthenticationConstants.transaction.name: json.encode(
          transaction.toJson())
    })
    .then((_) => Future.value())
    .catchError((error) => Future.error(AppgateSDKError.toError(error)));
  }

  Future<void> declinePushTransactionAction(TransactionInfo transaction) {
    return channel.invokeListMethod(
        MethodNames.declinePushTransactionAction.name, {
      _QRAuthenticationConstants.transaction.name: json.encode(
          transaction.toJson())
    })
    .then((_) => Future.value())
    .catchError((error) => Future.error(AppgateSDKError.toError(error)));
  }

  void approvePushAlertAction(TransactionInfo transaction) {
    channel.invokeListMethod(
        MethodNames.approvePushAlertAction.name, {
      _QRAuthenticationConstants.transaction.name: json.encode(
          transaction.toJson())
    }).then((_) {});
  }

}
