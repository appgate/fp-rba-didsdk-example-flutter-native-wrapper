package com.appgate.didsdk.modules

import android.content.Context
import com.appgate.appgate_sdk.data.utils.GsonUtil
import com.appgate.didm_auth.DetectID
import com.appgate.didm_auth.common.account.entities.Account
import com.appgate.didsdk.constants.ArgumentsConstants
import com.appgate.didsdk.constants.SDKErrors
import com.google.gson.Gson
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AccountsModule(context: Context?) {
    private var sdk: DetectID = DetectID.sdk(context)


    fun existAccounts(result: MethodChannel.Result) {
        val value: MutableList<Boolean> = ArrayList(1)
        value.add(sdk.existAccounts())
        result.success(value)
    }

    fun getAccounts(result: MethodChannel.Result) {
        val data = ArrayList<String>()
        sdk.accounts.map {
            data.add(Gson().toJson(it))
        }
        result.success(data)
    }
     fun setAccountUsername(call: MethodCall, result: MethodChannel.Result) {
        val accountJson = call.argument<String>(ArgumentsConstants.ACCOUNT.value)
        val account = GsonUtil.fromJson(accountJson, Account::class.java)
        val name = call.argument<String>(ArgumentsConstants.USERNAME.value)
        if (accountJson.isNullOrEmpty())
            result.error(
                SDKErrors.ERROR_NOT_ARGUMENTS.code, SDKErrors.ERROR_NOT_ARGUMENTS.message, SDKErrors.ERROR_NOT_ARGUMENTS.details
            )


        sdk.setAccountUsername(account, name)
        val value: MutableList<String> = ArrayList(1)
        value.add("")
        result.success(value)

    }
     fun removeAccount(call: MethodCall, result: MethodChannel.Result) {
        val accountJson = call.argument<String>(ArgumentsConstants.ACCOUNT.value)
        val account = GsonUtil.fromJson(accountJson, Account::class.java)
        if (accountJson.isNullOrEmpty())
            result.error(
                SDKErrors.ERROR_NOT_ARGUMENTS.code, SDKErrors.ERROR_NOT_ARGUMENTS.message, SDKErrors.ERROR_NOT_ARGUMENTS.details
            )

        sdk.removeAccount(account)
        val value: MutableList<String> = ArrayList(1)
        value.add("")
        result.success(value)

    }

     fun updateGlobalConfig(call: MethodCall, result: MethodChannel.Result) {
        val accountJson = call.argument<String>(ArgumentsConstants.ACCOUNT.value)
        val account = GsonUtil.fromJson(accountJson, Account::class.java)
        if (accountJson.isNullOrEmpty())
            result.error(
                SDKErrors.ERROR_NOT_ARGUMENTS.code, SDKErrors.ERROR_NOT_ARGUMENTS.message, SDKErrors.ERROR_NOT_ARGUMENTS.details
            )

        sdk.updateGlobalConfig(account)
        val value: MutableList<String> = ArrayList(1)
        value.add("")
        result.success(value)

    }

}