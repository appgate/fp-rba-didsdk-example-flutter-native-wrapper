part of didsdk;

enum _QRAuthenticationConstants {
  transaction,
  account,
  code,
}

class QRAuthenticationAPI {
  MethodChannel channel;

  QRAuthenticationAPI(this.channel);

  Future qrAuthenticationProcess(Account account, String qr) {
    return channel.invokeListMethod(
        MethodNames.qrAuthenticationProcess.name, {
          _QRAuthenticationConstants.account.name: json.encode(account.toJson()),
          _QRAuthenticationConstants.code.name: qr
    }).then((response) {
      if(response?.isNotEmpty ?? true) {
        return Future.value(TransactionInfo._getInstance(json.decode(response!.first)));
      } else {
        return Future.error(SDKErrors.defaultError);
      }
    }).catchError((error) => Future.error(AppgateSDKError.toError(error)));
  }

  Future confirmQRCodeTransactionAction(TransactionInfo transaction) {
    return channel.invokeListMethod(
        MethodNames.confirmQRCodeTransactionAction.name, {
      _QRAuthenticationConstants.transaction.name: json.encode(transaction.toJson())
    })
    .then((_) => Future.value())
    .catchError((error) => Future.error(AppgateSDKError.toError(error)));
  }

  Future declineQRCodeTransactionAction(TransactionInfo transaction) {
    return channel.invokeListMethod(
        MethodNames.declineQRCodeTransactionAction.name, {
      _QRAuthenticationConstants.transaction.name: json.encode(transaction.toJson())
    })
    .then((_) => Future.value())
    .catchError((error) => Future.error(AppgateSDKError.toError(error)));
  }

}
