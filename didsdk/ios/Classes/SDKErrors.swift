internal class SDKErrors {
    static let defaultError = FlutterError.init(code: "99", message: "Unknown library error", details: nil)
    static let errorNotArguments = FlutterError.init(code: "98", message: "Missing arguments", details: nil)
    static let errorChannelMethod = FlutterError.init(code: "99", message: "Unknown method in this channel", details: nil)
    static let ungrantedPushPermission = FlutterError.init(code: "85", message: "Ungranted Push Notifications permission", details: nil)
    static let invalidAPNS = FlutterError.init(code: "86", message: "Invalid APNS environment", details: nil)
}
