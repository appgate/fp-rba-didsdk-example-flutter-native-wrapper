part of didsdk;

class Didsdk {

  static final Didsdk _instance = Didsdk._channelName(DIDChannelNames.defaultChannel);

  late DIDModule _didModule;
  late AccountsAPI _accountsAPI;
  late QRAuthenticationAPI _qrAPI;
  late OtpAPI _otpAPI;
  late PushAPI _pushAPI;

  Didsdk._channelName(String prefix) {
    _didModule = DIDModule(MethodChannel(prefix));
    _accountsAPI = AccountsAPI(MethodChannel("${prefix}_${DIDChannelNames.accounts}"));
    _qrAPI = QRAuthenticationAPI(MethodChannel("${prefix}_${DIDChannelNames.qr}"));
    _otpAPI = OtpAPI(MethodChannel("${prefix}_${DIDChannelNames.otp}"));
    _pushAPI = PushAPI(MethodChannel("${prefix}_${DIDChannelNames.push}"));
  }

  // Registration
  static Future<void> didRegistrationWithUrl(String url) {
    return _instance._didModule.didRegistrationWithUrl(url);
  }
  static Future<void> didRegistrationByQRCode(String code, [String? url]) {
    return _instance._didModule.didRegistrationByQRCode(code, url ?? "");
  }

  // Common API
  static void setApplicationName(String name) {
    _instance._didModule.setApplicationName(name);
  }
  static Future<String> getMaskedAppInstanceID() {
    return _instance._didModule.getMaskedAppInstanceID();
  }
  static Future<String> getMobileID() {
    return _instance._didModule.getMobileID();
  }
  static void updateGlobalConfig(Account account) {
    getAccountsAPI().updateGlobalConfig(account);
  }

  static AccountsAPI getAccountsAPI() => _instance._accountsAPI;
  static QRAuthenticationAPI getQRAPI() => _instance._qrAPI;
  static OtpAPI getOTPAPI() => _instance._otpAPI;
  static PushAPI getPushAPI() => _instance._pushAPI;

}
