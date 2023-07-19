package com.appgate.didsdk.util

import android.content.Intent
import com.appgate.appgate_sdk.data.utils.GsonUtil
import com.appgate.didsdk.constants.ArgumentsConstants
import com.appgate.didsdk.constants.model.TransactionInfoDomain
import com.appgate.didsdk.modules.PushModule
import io.flutter.plugin.common.MethodChannel

class DIDPushUtil {
    fun getExtrasSendData(methodChannel: MethodChannel, intent: Intent) {
        val extras = intent.extras
        if (extras != null) {
            val extraTransaction = extras.getString(FT_TRANSACTION_INFO)
            if (extraTransaction != null) {
                val transactionInfo = GsonUtil.fromJson(
                    extraTransaction, TransactionInfoDomain::class.java
                )
                val typePush = extras.getInt(FT_TYPE_PUSH)
                val value = mapOf(
                    ArgumentsConstants.TRANSACTION.value to GsonUtil.toJson(transactionInfo)
                )
                when (typePush) {
                    DIDTypePush.PUSH_AUTH.code ->
                        methodChannel.invokeMethod(PushModule.PUSH_TRANSACTION, value)

                    DIDTypePush.PUSH_ALERT.code ->
                        methodChannel.invokeMethod(PushModule.PUSH_ALERT, value)
                }
            }
        }
    }

    companion object {
        private const val FT_TRANSACTION_INFO = "FTTransactionInfo"
        private const val FT_TYPE_PUSH = "FTTypePush"
    }
}