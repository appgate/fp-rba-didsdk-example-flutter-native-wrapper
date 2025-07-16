package com.appgate.didsdk.modules

import android.content.Context
import android.util.Log
import com.appgate.appgate_sdk.data.utils.GsonUtil
import com.appgate.appgate_sdk.encryptor.exceptions.SDKException
import com.appgate.didm_auth.DetectID
import com.appgate.didm_auth.common.account.entities.Account
import com.appgate.didm_auth.common.handler.TransactionResultHandler
import com.appgate.didsdk.DidsdkPlugin
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


        sdk.getQrApi().setQRCodeScanTransactionListener {
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
        sdk.getQrApi().setQRCodeTransactionServerResponseListener(listener)
        sdk.getQrApi().qrAuthenticationProcess(account, code)
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

        val transactionResultHandler = object : TransactionResultHandler {
            override fun onSuccess() {
                Log.d(TAG, "onSuccess()")
                val value: MutableList<String> = ArrayList(1)
                value.add("")
                result.success(value)
            }

            override fun onFailure(exception: SDKException) {
                Log.e(TAG, "onFailure: ", exception)
                result.error("${exception.code}", exception.message, exception.localizedMessage)
            }
        }

        when (confirm) {
            true -> {
                sdk.qrApi.confirmQRCodeTransactionAction(
                    transactionInfo,
                    transactionResultHandler
                )
            }
            else -> {
                sdk.qrApi.declineQRCodeTransactionAction(
                    transactionInfo,
                    transactionResultHandler
                )
            }
        }
    }

    companion object {
        private var TAG = DidsdkPlugin::class.java.simpleName
        const val CODE_SUCCESSFUL = "1020"
    }
}