package com.appgate.didsdk.constants.mapper

import com.appgate.appgate_sdk.data.utils.GsonUtil
import com.appgate.didm_auth.common.account.entities.Account
import com.appgate.didm_auth.common.transaction.TransactionInfo
import com.appgate.didsdk.constants.model.TransactionInfoDomain

class TransactionInfoMapper {

    fun mapFromModelSDK(model: TransactionInfo): TransactionInfoDomain {
        return TransactionInfoDomain(
            transactionID = model.transactionID,
            timeStamp = model.timeStamp.toString(),
            subject = model.subject,
            message = model.message,
            subjectNotification = model.subjectNotification,
            messageNotification = model.messageNotification,
            urlToResponse = model.urlToResponse,
            type = model.type,
            status = model.status,
            account = AccountMapper().mapFromModelSDK(model.account),
            transactionOfflineCode = model.transactionOfflineCode,
            transaction = model
        )
    }

    fun mapToModelSDK(model: TransactionInfoDomain): TransactionInfo {
        val transactionInfo = TransactionInfo()
        transactionInfo.transactionID = model.transactionID
        transactionInfo.timeStamp = model.timeStamp?.toLong() ?: 0
        transactionInfo.subject = model.subject
        transactionInfo.message = model.message
        transactionInfo.subjectNotification = model.subjectNotification
        transactionInfo.messageNotification = model.messageNotification
        transactionInfo.urlToResponse = model.urlToResponse
        transactionInfo.type = model.type
        transactionInfo.status = model.status
        transactionInfo.account =
            GsonUtil.fromJson(GsonUtil.toJson(model.account), Account::class.java)
        transactionInfo.transactionOfflineCode = model.transactionOfflineCode
        return transactionInfo
    }

}