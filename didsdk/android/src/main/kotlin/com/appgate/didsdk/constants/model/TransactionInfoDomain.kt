package com.appgate.didsdk.constants.model

import com.appgate.didm_auth.common.transaction.TransactionInfo

data class TransactionInfoDomain(
    val transactionID: String?,
    val timeStamp: String?,
    val subject: String?,
    val message: String?,
    val subjectNotification: String?,
    val messageNotification: String?,
    val urlToResponse: String?,
    val type: TransactionInfo.TransactionType?,
    val status: TransactionInfo.TransactionStatus?,
    var account: AccountDomain? = null,
    val transactionOfflineCode: String? = null,
    val transaction: TransactionInfo?,
)
