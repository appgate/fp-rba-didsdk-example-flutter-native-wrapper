import Flutter
import UIKit
import didm_sdk

fileprivate enum DIDAccountsMethods: String {
    case existAccounts
    case getAccounts
    case updateGlobalConfig
    case setAccountUsername
    case removeAccount
}

public class SwiftAccountsModule: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: ChannelNames.accountsModule.rawValue, binaryMessenger: registrar.messenger())
        let instance = SwiftAccountsModule()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
       switch call.method {
       case DIDAccountsMethods.existAccounts.rawValue:
           existAccounts(call, result)
           break
       case DIDAccountsMethods.getAccounts.rawValue:
           getAccounts(call, result)
           break
       case DIDAccountsMethods.updateGlobalConfig.rawValue:
           updateGlobalConfig(call, result)
           break
       case DIDAccountsMethods.setAccountUsername.rawValue:
           setAccountUsername(call, result)
           break
       case DIDAccountsMethods.removeAccount.rawValue:
           removeAccount(call, result)
           break
       default:
           result(SDKErrors.errorChannelMethod)
       }
    }
    
    static func getDIDAccount(from jsonString: String) -> Account? {
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Account.self, from: jsonData)
        } catch {
            return nil
        }
    }
    
    static func converDIDAccountToJson( account: Account) -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(account)
            guard let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else { return nil }
            return jsonDict
        } catch {}
        return nil
    }
    
    private func existAccounts(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result([(DetectID.sdk() as? DetectID)?.existAccounts() ?? false])
    }
    
    private func getAccounts(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result(getDIDAccounts())
    }
    
    private func updateGlobalConfig(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let accountJson = args[ArgumentsConstants.account] as? String,
              let account = SwiftAccountsModule.getDIDAccount(from: accountJson)
        else { return }
        (DetectID.sdk() as? DetectID)?.updateGlobalConfig(account)
    }
    
    private func setAccountUsername(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let username = args[ArgumentsConstants.username] as? String,
              let accountJson = args[ArgumentsConstants.account] as? String,
              let account = SwiftAccountsModule.getDIDAccount(from: accountJson)
        else { return }
        (DetectID.sdk() as? DetectID)?.setAccountUsername(username, for: account)
    }
    
    private func removeAccount(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let accountJson = args[ArgumentsConstants.account] as? String,
              let account = SwiftAccountsModule.getDIDAccount(from: accountJson)
        else { return }
        (DetectID.sdk() as? DetectID)?.remove(account)
        result([])
    }
    
    private func getDIDAccounts() -> [String] {
        guard let accounts = (DetectID.sdk() as? DetectID)?.getAccounts() as? [Any] else { return [] }
        return accounts.map({ a -> String? in
          do {
            if let account = a as? Account {
              let data = try JSONEncoder().encode(account)
                return String(data: data, encoding: .utf8)
            }
          } catch {}
          return nil
        }).compactMap({ $0 })
    }

}
