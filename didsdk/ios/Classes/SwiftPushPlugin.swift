//
//  SwiftPushPlugin.swift
//  didsdk
//
//  Created by Camilo Ortegon on 5/17/23.
//

import Flutter
import UIKit
import didm_sdk

fileprivate enum SwiftPushMethods: String {
    case setPushTransactionOpenListener
    case setPushAlertOpenListener
    case confirmPushTransactionAction
    case declinePushTransactionAction
    case approvePushAlertAction
    case push_transaction
    case push_alert
    case server_response
}

public class SwiftPushPlugin: NSObject, FlutterPlugin {
    
    static var instance: SwiftPushPlugin!
    
    let channel: FlutterMethodChannel!
    var launchOptions: NSDictionary?
    var setupError: FlutterError?
    var transactions: [String: TransactionInfo] = [:]
    
    init(_ registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: ChannelNames.pushModule.rawValue, binaryMessenger: registrar.messenger())
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftPushPlugin.instance = SwiftPushPlugin(registrar)
        registrar.addMethodCallDelegate(instance, channel: instance.channel)
        registrar.addApplicationDelegate(instance)
        instance.setDelegates()
    }
    
    fileprivate func setDelegates() {
        guard let sdk = DetectID.sdk() as? DetectID else { return }
        sdk.getPushApi().pushAlertOpenDelegate = self
        sdk.getPushApi().pushTransactionOpenDelegate = self
        sdk.getPushApi().pushTransactionServerResponseDelegate = self
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case SwiftPushMethods.setPushTransactionOpenListener.rawValue:
            finishPayloadSubscription()
            if let error = self.setupError {
                result(error)
            } else {
                result([""])
            }
            break
        case SwiftPushMethods.setPushAlertOpenListener.rawValue:
            if let error = self.setupError {
                result(error)
            } else {
                result([""])
            }
            finishPayloadSubscription()
            break
        case SwiftPushMethods.confirmPushTransactionAction.rawValue:
            confirmOrDecline(true, call, result)
            break
        case SwiftPushMethods.declinePushTransactionAction.rawValue:
            confirmOrDecline(false, call, result)
            break
        case SwiftPushMethods.approvePushAlertAction.rawValue:
            approveAlert(call)
            result([""])
            break
        default:
            result(SDKErrors.errorChannelMethod)
        }
    }
    
    private func confirmOrDecline(_ confirm: Bool, _ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = ArgumentsHelper.parseParams(call),
              let transactionJson = args[ArgumentsConstants.transaction] as? String,
              let transaction = getTransactionInfo(transactionJson)
        else { return }
        if confirm {
            (DetectID.sdk() as? DetectID)?.getPushApi()
            .confirmPushTransactionAction(transaction, onSuccess: {
                DispatchQueue.main.async(execute: {
                    result([""])
                })
            }, onFailure: { error in
                DispatchQueue.main.async(execute: {
                    result(FlutterError.init(code: "\(error.code)", message: error.description, details: nil))
                })
            })
        } else {
            (DetectID.sdk() as? DetectID)?.getPushApi()
            .declinePushTransactionAction(transaction, onSuccess: {
                DispatchQueue.main.async(execute: {
                    result([""])
                })
            }, onFailure: { error in
                DispatchQueue.main.async(execute: {
                    result(FlutterError.init(code: "\(error.code)", message: error.description, details: nil))
                })
            })
        }
    }
    
    private func approveAlert(_ call: FlutterMethodCall) {
        guard let args = ArgumentsHelper.parseParams(call),
              let transactionJson = args[ArgumentsConstants.transaction] as? String,
              let transaction = getTransactionInfo(transactionJson)
        else { return }
        (DetectID.sdk() as? DetectID)?.getPushApi().approvePushAlertAction(transaction)
    }
    
    private func getTransactionInfo(_ jsonString: String) -> TransactionInfo? {
        do {
            guard let data = jsonString.data(using: .utf8),
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let transactionID = json[TransactionInfoKeys.transactionID.rawValue] as? String else {
                return nil
            }
            return transactions[transactionID]
        } catch {
            return nil
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        registerForRemoteNotifications()
        subscribePayload(launchOptions)
        return true
    }
    
    private func subscribePayload(_ dictionary: [AnyHashable : Any]) {
        self.launchOptions = dictionary[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary
    }
    
    private func finishPayloadSubscription() {
        guard let payload = launchOptions else { return }
        self.launchOptions = nil
        (DetectID.sdk() as? DetectID)?.subscribePayload(payload as! [AnyHashable : Any])
    }
    
    private func registerForRemoteNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            } else {
                self.setupError = SDKErrors.ungrantedPushPermission
                print(error as Any)
            }
        }
    }
    
}

extension SwiftPushPlugin {
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.setupError = SDKErrors.invalidAPNS
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        (DetectID.sdk() as? DetectID)?.receivePushServiceId(deviceToken)
    }
}

extension SwiftPushPlugin: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        (DetectID.sdk() as? DetectID)?.subscribePayload(notification, withCompletionHandler: completionHandler)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        (DetectID.sdk() as? DetectID)?.handleAction(withIdentifier: response)
    }
    
}

extension SwiftPushPlugin: PushTransactionOpenDelegate {
    
    public func onPushTransactionOpen(_ transaction: TransactionInfo!) {
        transactions[transaction.transactionID] = transaction
        guard let jsonString = TransactionConverter.toJSON(with: transaction) else { return }
        channel.invokeMethod(SwiftPushMethods.push_transaction.rawValue, arguments: [
            ArgumentsConstants.transaction: jsonString
        ])
    }
}

extension SwiftPushPlugin: PushTransactionServerResponseDelegate {
    
    public func onPushTransactionServerResponse(_ response: String!) {
        channel.invokeMethod(SwiftPushMethods.server_response.rawValue, arguments: [
            ArgumentsConstants.code: response
        ])
    }
}

extension SwiftPushPlugin: PushAlertOpenDelegate {
    
    public func onPushAlertOpen(_ transaction: TransactionInfo!) {
        transactions[transaction.transactionID] = transaction
        guard let jsonString = TransactionConverter.toJSON(with: transaction) else { return }
        channel.invokeMethod(SwiftPushMethods.push_alert.rawValue, arguments: [
            ArgumentsConstants.transaction: jsonString
        ])
    }
}
