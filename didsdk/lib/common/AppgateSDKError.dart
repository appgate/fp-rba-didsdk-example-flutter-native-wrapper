part of didsdk;

class AppgateSDKError implements PlatformException {
  @override
  final String code;
  @override
  final String? message;
  @override
  final dynamic details;
  @override
  final String? stacktrace;

  AppgateSDKError({
    required this.code,
    this.message,
    this.details,
    this.stacktrace,
  });

  factory AppgateSDKError.toError(dynamic error) {
    if (error is PlatformException) {
      return AppgateSDKError(code: error.code, message: error.message);
    }
    return SDKErrors.defaultError;
  }
}
