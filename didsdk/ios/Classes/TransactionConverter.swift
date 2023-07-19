//
//  File.swift
//  didsdk
//
//  Created by Camilo Ortegon on 5/18/23.
//

import Foundation
import didm_sdk

enum TransactionInfoKeys: String {
    case account
    case transactionID
    case type
    case status
    case subject
    case message
    case subjectNotification
    case messageNotification
    case urlToResponse
    case timeStamp
    case transactionOfflineCode
}

class TransactionConverter {
    
    static func toJSON(with transaction: TransactionInfo) -> String? {
        let json: [String: Any] = [
            TransactionInfoKeys.account.rawValue: SwiftAccountsModule.converDIDAccountToJson(account: transaction.account) as Any,
            TransactionInfoKeys.transactionID.rawValue: transaction.transactionID as Any,
            TransactionInfoKeys.type.rawValue: transaction.type.toName() as Any,
            TransactionInfoKeys.status.rawValue: transaction.status.toName() as Any,
            TransactionInfoKeys.subject.rawValue: transaction.subject as Any,
            TransactionInfoKeys.message.rawValue: transaction.message as Any,
            TransactionInfoKeys.subjectNotification.rawValue: transaction.subjectNotification as Any,
            TransactionInfoKeys.messageNotification.rawValue: transaction.messageNotification as Any,
            TransactionInfoKeys.urlToResponse.rawValue: transaction.urlToResponse as Any,
            TransactionInfoKeys.timeStamp.rawValue: transaction.timeStamp as Any,
            TransactionInfoKeys.transactionOfflineCode.rawValue: transaction.transactionOfflineCode as Any
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

extension TransactionType {
    func toName() -> String {
        switch self {
        case .NONE:
            return "NONE"
        case .PUSH_AUTHENTICATION:
            return "PUSH_AUTHENTICATION"
        case .PUSH_ALERT:
            return "PUSH_ALERT"
        case .BIOMETRIC_AUTHENTICATION:
            return "BIOMETRIC_AUTHENTICATION"
        @unknown default:
            return "NONE"
        }
    }
}

extension TransactionStatus {
    func toName() -> String {
        switch self {
        case .ALL:
            return "ALL"
        case .APPROVED:
            return "APPROVED"
        case .PENDING:
            return "PENDING"
        case .NOT_APPROVED:
            return "NOT_APPROVED"
        case .EXPIRED:
            return "EXPIRED"
        case .MAX_WRONG_ATTEMPTS:
            return "MAX_WRONG_ATTEMPTS"
        @unknown default:
            return ""
        }
    }
}
