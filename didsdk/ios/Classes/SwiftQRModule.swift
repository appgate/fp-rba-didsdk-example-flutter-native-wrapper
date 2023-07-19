import Flutter
import UIKit
import didm_sdk

fileprivate enum DIDQRParams: String {
    case transactionID
}

fileprivate enum DIDQRMethods: String {
    case qrAuthenticationProcess
    case confirmQRCodeTransactionAction
    case declineQRCodeTransactionAction
}

public class SwiftQRModule: NSObject, FlutterPlugin {
    
    static let successResponseCode = "1020"
    
    var lastTransaction: TransactionInfo?
    var callback: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: ChannelNames.qrModule.rawValue, binaryMessenger: registrar.messenger())
        let instance = SwiftQRModule()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case DIDQRMethods.qrAuthenticationProcess.rawValue:
            qrAuthenticationProcess(call, result)
            break
        case DIDQRMethods.confirmQRCodeTransactionAction.rawValue:
            confirmOrDecline(true, call, result)
            break
        case DIDQRMethods.declineQRCodeTransactionAction.rawValue:
            confirmOrDecline(false, call, result)
            break
        default:
            result(SDKErrors.errorChannelMethod)
        }
    }
    
    private func setupDelegates() {
        (DetectID.sdk() as? DetectID)?.getQrApi().qrCodeScanTransactionDelegate = self
        (DetectID.sdk() as? DetectID)?.getQrApi().qrCodeTransactionServerResponseDelegate = self
    }
    
    private func qrAuthenticationProcess(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let accountJson = args[ArgumentsConstants.account] as? String,
              let account = SwiftAccountsModule.getDIDAccount(from: accountJson),
              let code = args[ArgumentsConstants.code] as? String,
              !code.isEmpty
        else {
            result(SDKErrors.errorNotArguments)
            return
        }
        setupDelegates()
        self.callback = result
        (DetectID.sdk() as? DetectID)?.getQrApi().qrAuthenticationProcess(account, withQrContent: code)
    }
    
    private func confirmOrDecline(_ confirm: Bool, _ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let transactionJson = args[ArgumentsConstants.transaction] as? String,
              let transactionID = getTransactionID(transactionJson)
        else {
            result(SDKErrors.errorNotArguments)
            return
        }
        guard let transaction = lastTransaction,
              transaction.transactionID == transactionID
        else {
            result(SDKErrors.defaultError);
            return
        }
        lastTransaction = nil
        setupDelegates()
        self.callback = result
        if confirm {
            (DetectID.sdk() as? DetectID)?.getQrApi().confirmQRCodeTransactionAction(transaction)
        } else {
            (DetectID.sdk() as? DetectID)?.getQrApi().declineQRCodeTransactionAction(transaction)
        }
    }
    
    private func getTransactionID(_ jsonString: String) -> String? {
        do {
            guard let data = jsonString.data(using: .utf8),
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let transactionID = json[DIDQRParams.transactionID.rawValue] as? String else {
                return nil
            }
            return transactionID
        } catch {
            return nil
        }
    }

}

extension SwiftQRModule: QRCodeScanTransactionDelegate {
    public func onQRCodeScanTransaction(_ transaction: TransactionInfo) {
        self.lastTransaction = transaction
        if let jsonString = TransactionConverter.toJSON(with: transaction) {
            callback?([jsonString])
        } else {
            callback?(SDKErrors.defaultError)
        }
        self.callback = nil
    }
}

extension SwiftQRModule: QRCodeTransactionServerResponseDelegate {
    
    public func onQRCodeTransactionServerResponse(_ response: String) {
        if response == SwiftQRModule.successResponseCode {
            self.callback?([])
        } else {
            self.callback?(FlutterError.init(code: "\(response)", message: "", details: nil))
        }
        self.callback = nil
    }
}
