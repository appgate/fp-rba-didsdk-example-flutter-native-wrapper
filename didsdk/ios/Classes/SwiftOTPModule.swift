import Flutter
import UIKit
import didm_sdk

fileprivate enum DIDOTPMethods: String {
    case getTokenValue
    case getTokenTimeStepValue
    case getChallengeQuestionOtp
}

public class SwiftOTPModule: NSObject, FlutterPlugin {

    var challengeCallback: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: ChannelNames.otpModule.rawValue, binaryMessenger: registrar.messenger())
        let instance = SwiftOTPModule()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case DIDOTPMethods.getTokenValue.rawValue:
            getTokenValue(call, result)
            break
        case DIDOTPMethods.getTokenTimeStepValue.rawValue:
            getTokenTimeStepValue(call, result)
            break
        case DIDOTPMethods.getChallengeQuestionOtp.rawValue:
            getChallengeQuestionOtp(call, result)
            break
        default:
            result(SDKErrors.errorChannelMethod)
        }
    }

    private func getTokenValue(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let accountJson = args[ArgumentsConstants.account] as? String,
              let account = SwiftAccountsModule.getDIDAccount(from: accountJson)
        else {
            result([""])
            return
        }
        result([(DetectID.sdk() as? DetectID)?.getOtpApi().getTokenValue(account) ?? ""])
    }

    private func getTokenTimeStepValue(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let accountJson = args[ArgumentsConstants.account] as? String,
              let account = SwiftAccountsModule.getDIDAccount(from: accountJson)
        else {
            result([""])
            return
        }
        result([(DetectID.sdk() as? DetectID)?.getOtpApi().getTokenTimeStepValue(account) ?? 0])
    }

    private func getChallengeQuestionOtp(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let accountJson = args[ArgumentsConstants.account] as? String,
              let account = SwiftAccountsModule.getDIDAccount(from: accountJson),
              let answer = args[ArgumentsConstants.answer] as? String,
              !answer.isEmpty
        else {
            result(SDKErrors.errorNotArguments)
            return
        }
        self.challengeCallback = result
        (DetectID.sdk() as? DetectID)?.getOtpApi().onClientArgumentsDelegate = self
        let response = (DetectID.sdk() as? DetectID)?.getOtpApi().getChallengeQuestionOtp(with: account, answer: answer) ?? ""
        if response == "Error" {
            result(SDKErrors.errorNotArguments)
        } else {
            challengeCallback?([response])
        }
        self.challengeCallback = nil
    }

}

extension SwiftOTPModule: OnClientArgumentsErrors {

    public func onInvalidChallengeLength(length: Int, reason: String) {
        self.challengeCallback?(FlutterError.init(code: "88", message: reason, details: nil))
        self.challengeCallback = nil
    }

    public func onMissingPassword(reason: String) {
    }
}
