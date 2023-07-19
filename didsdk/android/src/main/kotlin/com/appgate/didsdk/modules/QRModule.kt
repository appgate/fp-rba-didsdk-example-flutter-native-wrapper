package com.appgate.didsdk.modules

import android.content.Context
import com.appgate.appgate_sdk.data.utils.GsonUtil
import com.appgate.didm_auth.DetectID
import com.appgate.didm_auth.common.account.entities.Account
import com.appgate.didm_auth.qr.listener.QRCodeTransactionServerResponseListener
import com.appgate.didsdk.constants.ArgumentsConstants
import com.appgate.didsdk.constants.SDKErrors
import com.appgate.didsdk.constants.mapper.TransactionInfoMapper
import com.appgate.didsdk.constants.model.TransactionInfoDomain
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class QRModule(context: Context?) {
    private var sdk: DetectID = DetectID.sdk(context)
    fun qrAuthenticationProcess(call: MethodCall, result: MethodChannel.Result) {

        val accountJson = call.argument<String>(ArgumentsConstants.ACCOUNT.value)
        val code = call.argument<String>(ArgumentsConstants.CODE.value)
        val account = GsonUtil.fromJson(accountJson, Account::class.java)
        if (code.isNullOrEmpty() && accountJson.isNullOrEmpty())
            result.error(
                SDKErrors.ERROR_NOT_ARGUMENTS.code,
                SDKErrors.ERROR_NOT_ARGUMENTS.message,
                SDKErrors.ERROR_NOT_ARGUMENTS.details
            )


        sdk.qrApi.setQRCodeScanTransactionListener {
            if (it != null) {
                val value: MutableList<String> = ArrayList(1)
                value.add(GsonUtil.toJson(TransactionInfoMapper().mapFromModelSDK(it)))
                result.success(value)
            } else {
                result.error(
                    SDKErrors.DEFAULT_ERROR.code,
                    SDKErrors.DEFAULT_ERROR.message,
                    SDKErrors.DEFAULT_ERROR.details
                )
            }
        }

        val listener = QRCodeTransactionServerResponseListener { data: String ->
            if (data != CODE_SUCCESSFUL) {
                result.error(
                    SDKErrors.DEFAULT_ERROR.code,
                    SDKErrors.DEFAULT_ERROR.message,
                    SDKErrors.DEFAULT_ERROR.details
                )

            }
        }
        sdk.qrApi.setQRCodeTransactionServerResponseListener(listener)
        sdk.qrApi.qrAuthenticationProcess(account, code)
    }

    fun confirmOrDecline(confirm: Boolean, call: MethodCall, result: MethodChannel.Result) {

        val transaction = call.argument<String>(ArgumentsConstants.TRANSACTION.value)
        if (transaction.isNullOrEmpty())
            result.error(
                SDKErrors.ERROR_NOT_ARGUMENTS.code,
                SDKErrors.ERROR_NOT_ARGUMENTS.message,
                SDKErrors.ERROR_NOT_ARGUMENTS.details
            )
        val transactionInfoDomain: TransactionInfoDomain =
            GsonUtil.fromJson(transaction, TransactionInfoDomain::class.java)
        val transactionInfo = TransactionInfoMapper().mapToModelSDK(transactionInfoDomain)

        val listener = QRCodeTransactionServerResponseListener {
            if (it == CODE_SUCCESSFUL) {
                val value: MutableList<String> = ArrayList(1)
                value.add("")
                result.success(value)
            } else {
                result.error(it, "", null)
            }
        }
        sdk.qrApi.setQRCodeTransactionServerResponseListener(listener)

        when (confirm) {
            true -> {
                sdk.qrApi.confirmQRCodeTransactionAction(transactionInfo)
            }

            else -> {
                sdk.qrApi.declineQRCodeTransactionAction(transactionInfo)
            }
        }


    }

    companion object {
        const val CODE_SUCCESSFUL = "1020"
    }
}