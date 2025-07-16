import Flutter
import UIKit
import didm_sdk
import didm_core
import appgate_sdk

fileprivate enum DIDModulesNames: String {
    case didRegistrationWithUrl
    case didRegistrationByQRCode
    case setApplicationName
    case getMaskedAppInstanceID
    case getMobileID
}

public class SwiftDidsdkPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: ChannelNames.didModule.rawValue, binaryMessenger: registrar.messenger())
        let instance = SwiftDidsdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case DIDModulesNames.didRegistrationWithUrl.rawValue:
            didRegistrationWithUrl(call, result)
            break
        case DIDModulesNames.didRegistrationByQRCode.rawValue:
            didRegistrationByQRCode(call, result)
            break
        case DIDModulesNames.setApplicationName.rawValue:
            setApplicationName(call)
            break
        case DIDModulesNames.getMaskedAppInstanceID.rawValue:
            getMaskedAppInstanceID(call, result)
            break
        case DIDModulesNames.getMobileID.rawValue:
            getMobileID(call, result)
            break
        default:
            result(SDKErrors.errorChannelMethod)
        }
    }
    
    func didRegistrationWithUrl(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let url = args[ArgumentsConstants.url] as? String,
              !url.isEmpty
        else {
            result(SDKErrors.errorNotArguments)
            return
        }
        (DetectID.sdk() as? DetectID)?.didRegistration(withUrl: url as String, onSuccess: {
            DispatchQueue.main.async(execute: {
                result([""])
            })
        }, onFailure: { error in
            DispatchQueue.main.async(execute: {
                result(FlutterError.init(code: "\(error.code)", message: error.description, details: nil))
            })
        })
    }
    
    func didRegistrationByQRCode(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let code = args[ArgumentsConstants.code] as? String,
              let url = args[ArgumentsConstants.url] as? String,
              !code.isEmpty
        else {
            result(SDKErrors.errorNotArguments)
            return
        }
        (DetectID.sdk() as? DetectID)?.didRegistration(byQRCode: code, fromUrl: url, onSuccess: {
            DispatchQueue.main.async(execute: {
                result([""])
            })
        }, onFailure: { error in
            DispatchQueue.main.async(execute: {
                result(FlutterError.init(code: "\(error.code)", message: error.description, details: nil))
            })
        })
    }
    
    func setApplicationName(_ call: FlutterMethodCall) {
        guard let args = ArgumentsHelper.parseParams(call),
              let name = args[ArgumentsConstants.name] as? String,
              !name.isEmpty
        else { return }
        (DetectID.sdk() as? DetectID)?.setApplicationName(name)
    }
    
    func getMaskedAppInstanceID(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result([(DetectID.sdk() as? DetectID)?.getMaskedAppInstanceID() ?? ""])
    }
    
    func getMobileID(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result([(DetectID.sdk() as? DetectID)?.getMobileID() ?? ""])
    }

}
