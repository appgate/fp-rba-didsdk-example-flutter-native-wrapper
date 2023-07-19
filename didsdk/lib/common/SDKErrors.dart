part of didsdk;

class SDKErrors {
  static final platformError = AppgateSDKError(
      code: '98', message: 'This method is not available in this platform.');
  static final defaultError = AppgateSDKError(code: '99');

}
