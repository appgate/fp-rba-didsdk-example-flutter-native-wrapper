part of didsdk;

enum _AccountsAPIConstants {
  username,
  account,
}

class AccountsAPI {
  MethodChannel channel;

  AccountsAPI(this.channel);

  Future<bool> existAccounts() {
    return channel.invokeListMethod(
        MethodNames.existAccounts.name, {}).then((response) {
      if ((response?.isNotEmpty ?? false) && response!.first is bool) {
        bool value = response.first;
        return Future.value(value);
      }
      return Future.value(false);
    }).catchError((_) => Future.value(false));
  }

  Future getAccounts() {
    return channel.invokeListMethod(MethodNames.getAccounts.name, {})
    .then((accounts) {
      List<Account> list = accounts?.map((e) {
        return Account._getInstance(json.decode(e));
      }).toList() ?? [];
      return Future.value(list);
    }).catchError((_) async => []);
  }

  void updateGlobalConfig(Account account) {
    channel.invokeListMethod(MethodNames.updateGlobalConfig.name, {
      _AccountsAPIConstants.account.name: json.encode(account.toJson())
    })
    .then((_) {})
    .catchError((error) => {});
  }

  void setAccountUsername(String username, Account account) {
    channel.invokeListMethod(MethodNames.setAccountUsername.name, {
      _AccountsAPIConstants.username.name: username,
      _AccountsAPIConstants.account.name: json.encode(account.toJson())
    })
    .then((_) {})
    .catchError((error) => {});
  }

  Future<void> removeAccount(Account account) {
    return channel.invokeListMethod(MethodNames.removeAccount.name, {
      _AccountsAPIConstants.account.name: json.encode(account.toJson())
    })
    .then((_) => Future.delayed(const Duration(milliseconds: 100)))
    .catchError((error) => {});
  }

}
