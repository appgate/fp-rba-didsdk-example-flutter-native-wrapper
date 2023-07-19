part of didsdk;

enum _DIDModuleConstants {
  code,
  name,
  url,
}

class DIDModule {
  MethodChannel channel;

  DIDModule(this.channel);

  Future<void> didRegistrationWithUrl(String url) {
    return channel.invokeListMethod(MethodNames.didRegistrationWithUrl.name, {
      _DIDModuleConstants.url.name: url
    })
    .then((_) => Future.value())
    .catchError((error) => Future.error(AppgateSDKError.toError(error)));
  }

  Future<void> didRegistrationByQRCode(String code, String url) {
    return channel.invokeListMethod(MethodNames.didRegistrationByQRCode.name, {
      _DIDModuleConstants.code.name: code,
      _DIDModuleConstants.url.name: url
    })
    .then((_) => Future.value())
    .catchError((error) => Future.error(AppgateSDKError.toError(error)));
  }

  void setApplicationName(String name) {
    channel.invokeListMethod(MethodNames.setApplicationName.name, {
      _DIDModuleConstants.name.name: name
    })
    .then((_) => {})
    .catchError((_) => {});
  }

  Future<String> getMaskedAppInstanceID() {
    return channel.invokeListMethod(MethodNames.getMaskedAppInstanceID.name, {})
    .then((response) async => (response?.isNotEmpty ?? false) ? response!.first as String : "")
    .catchError((_) async => "");
  }

  Future<String> getMobileID() {
    return channel.invokeListMethod(MethodNames.getMobileID.name, {})
    .then((response) async => (response?.isNotEmpty ?? false) ? response!.first as String : "")
    .catchError((_) async => "");
  }

}
