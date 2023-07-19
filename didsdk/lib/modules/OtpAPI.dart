part of didsdk;

enum _OtpAPIConstants {
  account,
  answer,
}

class OtpAPI {
  MethodChannel channel;

  OtpAPI(this.channel);

  Future<String> getTokenValue(Account account) {
    return channel.invokeListMethod(MethodNames.getTokenValue.name, {
      _OtpAPIConstants.account.name: json.encode(account.toJson())
    })
    .then((response) async => ((response?.isNotEmpty ?? false) ? response!.first : ""));
  }

  Future<int> getTokenTimeStepValue(Account account) {
    return channel.invokeListMethod(MethodNames.getTokenTimeStepValue.name, {
      _OtpAPIConstants.account.name: json.encode(account.toJson())
    })
    .then((response) async => ((response?.isNotEmpty ?? false) ? int.parse("${response!.first}") : 0));
  }

  Future getChallengeQuestionOtp(Account account, String answer) {
    return channel.invokeListMethod(MethodNames.getChallengeQuestionOtp.name, {
      _OtpAPIConstants.account.name: json.encode(account.toJson()),
      _OtpAPIConstants.answer.name: answer,
    })
    .then((response) async => ((response?.isNotEmpty ?? false) ? response!.first : ""))
    .catchError((error) => Future.error(AppgateSDKError.toError(error)));
  }
}
