package com.appgate.didsdk.modules

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.appgate.appgate_sdk.data.utils.GsonUtil
import com.appgate.didm_auth.DetectID
import com.appgate.didm_auth.push_auth.transaction.listener.PushTransactionServerResponseListener
import com.appgate.didsdk.constants.ArgumentsConstants
import com.appgate.didsdk.constants.SDKErrors
import com.appgate.didsdk.constants.mapper.TransactionInfoMapper
import com.appgate.didsdk.constants.model.TransactionInfoDomain
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class PushModule(private val context: Context?, private val channel: MethodChannel) {
    private var sdk: DetectID = DetectID.sdk(context)
    private val handler = Handler(Looper.getMainLooper())

    init {
        val pushTransactionViewProperties = sdk.pushTransactionViewPropertiesInstance
        pushTransactionViewProperties.enableNotificationQuickActions = false
        pushTransactionViewProperties.notificationIconResource = 0;
        sdk.pushApi.setPushTransactionViewProperties(pushTransactionViewProperties)
    }

    fun setPushTransactionOpenListener(result: MethodChannel.Result) {
        sdk.pushApi.setPushTransactionOpenListener {
            if (it != null) {
                handler.post {
                    val value = mapOf(
                        ArgumentsConstants.TRANSACTION.value to GsonUtil.toJson(
                            TransactionInfoMapper().mapFromModelSDK(it)
                        )
                    )
                    channel.invokeMethod(PUSH_TRANSACTION, value)
                }
            }
        }
        result.success(listOf(""))
    }

    fun confirmOrDecline(
        confirm: Boolean, call: MethodCall, result: MethodChannel.Result
    ) {
        val transaction = call.argument<String>(ArgumentsConstants.TRANSACTION.value)
        if (transaction.isNullOrEmpty()) result.error(
            SDKErrors.ERROR_NOT_ARGUMENTS.code,
            SDKErrors.ERROR_NOT_ARGUMENTS.message,
            SDKErrors.ERROR_NOT_ARGUMENTS.details
        )
        val transactionInfoDomain: TransactionInfoDomain =
            GsonUtil.fromJson(transaction, TransactionInfoDomain::class.java)
        val transactionInfo = TransactionInfoMapper().mapToModelSDK(transactionInfoDomain)

        val listener = PushTransactionServerResponseListener {
            if (it != null) {
                handler.post {
                    val value = mapOf(
                        ArgumentsConstants.CODE.value to it
                    )
                    channel.invokeMethod(SERVER_RESPONSE, value)
                }
            }
        }
        sdk.pushApi.setPushTransactionServerResponseListener(listener)

        when (confirm) {
            true -> {
                sdk.pushApi.confirmPushTransactionAction(transactionInfo)
            }

            else -> {
                sdk.pushApi.declinePushTransactionAction(transactionInfo)
            }
        }

        result.success(listOf(""))
    }

    fun approvePush(call: MethodCall, result: MethodChannel.Result) {
        val transaction = call.argument<String>(ArgumentsConstants.TRANSACTION.value)
        if (transaction.isNullOrEmpty()) result.error(
            SDKErrors.ERROR_NOT_ARGUMENTS.code,
            SDKErrors.ERROR_NOT_ARGUMENTS.message,
            SDKErrors.ERROR_NOT_ARGUMENTS.details
        )
        val transactionInfoDomain: TransactionInfoDomain =
            GsonUtil.fromJson(transaction, TransactionInfoDomain::class.java)
        val transactionInfo = TransactionInfoMapper().mapToModelSDK(transactionInfoDomain)
        sdk.pushApi.approvePushAlertAction(transactionInfo)
        result.success(listOf(""))
    }

    fun setPushAlertOpenListener(result: MethodChannel.Result) {
        result.success(listOf(""))
        sdk.pushApi.setPushAlertOpenListener {
            if (it != null) {
                val value = mapOf(
                    ArgumentsConstants.TRANSACTION.value to GsonUtil.toJson(
                        TransactionInfoMapper().mapFromModelSDK(it)
                    )
                )
                channel.invokeMethod(PUSH_ALERT, value)
            }
        }
    }

    companion object {
        const val PUSH_ALERT = "push_alert"
        const val SERVER_RESPONSE = "server_response"
        const val PUSH_TRANSACTION = "push_transaction"
        const val FT_TRANSACTION_INFO = "FTTransactionInfo"
        const val FT_TYPE_PUSH = "FTTypePush"
    }
}