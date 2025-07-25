part of didsdk;

enum _AccountAttributes {
  username,
  organizationName,
  activeOTPAuth,
  activePushAuth,
  activeQRAuth,
  activePushAlert,
  activeFaceAuth,
  registrationDate,
  activationURL,
  registrationMethod,
}

class Account {

  final String username;
  final String organizationName;
  final String registrationDate;
  final String activationURL;
  final int registrationMethod;
  final bool activeOTPAuth;
  final bool activePushAuth;
  final bool activeQRAuth;
  final bool activePushAlert;
  final bool activeFaceAuth;

  Account._(
      this.username,
      this.organizationName,
      this.registrationDate,
      this.activationURL,
      this.registrationMethod,
      this.activeOTPAuth,
      this.activePushAuth,
      this.activeQRAuth,
      this.activePushAlert,
      this.activeFaceAuth,
  );

  Map<String, dynamic> toJson() => {
    _AccountAttributes.username.name: username,
    _AccountAttributes.organizationName.name: organizationName,
    _AccountAttributes.activeOTPAuth.name: activeOTPAuth,
    _AccountAttributes.activePushAuth.name: activePushAuth,
    _AccountAttributes.activeQRAuth.name: activeQRAuth,
    _AccountAttributes.activePushAlert.name: activePushAlert,
    _AccountAttributes.activeFaceAuth.name: activeFaceAuth,
    _AccountAttributes.registrationDate.name: registrationDate,
    _AccountAttributes.activationURL.name: activationURL,
    _AccountAttributes.registrationMethod.name: registrationMethod,
  };

  factory Account._getInstance(Map map) {
    return Account._(
      _JsonMapper._getString(map, _AccountAttributes.username.name),
      _JsonMapper._getString(map, _AccountAttributes.organizationName.name),
      _JsonMapper._getString(map, _AccountAttributes.registrationDate.name),
      _JsonMapper._getString(map, _AccountAttributes.activationURL.name),
      _JsonMapper._getInt(map, _AccountAttributes.registrationMethod.name),
      _JsonMapper._getBool(map, _AccountAttributes.activeOTPAuth.name),
      _JsonMapper._getBool(map, _AccountAttributes.activePushAuth.name),
      _JsonMapper._getBool(map, _AccountAttributes.activeQRAuth.name),
      _JsonMapper._getBool(map, _AccountAttributes.activePushAlert.name),
      _JsonMapper._getBool(map, _AccountAttributes.activeFaceAuth.name),
    );
  }
}
