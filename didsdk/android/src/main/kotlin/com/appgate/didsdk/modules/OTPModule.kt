package com.appgate.didsdk.modules

import android.content.Context
import android.util.Log
import com.appgate.appgate_sdk.data.utils.GsonUtil
import com.appgate.didm_auth.DetectID
import com.appgate.didm_auth.common.account.entities.Account
import com.appgate.didsdk.constants.ArgumentsConstants
import com.appgate.didsdk.constants.SDKErrors
import com.appgate.token.challenge.otp.api.OnClientArgumentsErrors
import com.appgate.token.challenge.otp.api.OnServerParametersErrors
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class OTPModule(context: Context?) {
    private var sdk: DetectID = DetectID.sdk(context)

    fun getTokenValue(call: MethodCall, result: MethodChannel.Result) {
        val accountJson = call.argument<String>(ArgumentsConstants.ACCOUNT.value)
        val account = GsonUtil.fromJson(accountJson, Account::class.java)
        val value: MutableList<String> = ArrayList(1)

        if (accountJson.isNullOrEmpty()) {
            value.add("")
            result.success(value)
            return
        }

        value.add(sdk.otpApi.getTokenValue(account))
        result.success(value)

    }

    fun getTokenTimeStepValue(call: MethodCall, result: MethodChannel.Result) {
        val accountJson = call.argument<String>(ArgumentsConstants.ACCOUNT.value)
        val account = GsonUtil.fromJson(accountJson, Account::class.java)
        if (accountJson.isNullOrEmpty()) {
            val value: MutableList<String> = ArrayList(1)
            value.add("")
            result.success(value)
            return
        }

        val value: MutableList<Int> = ArrayList(1)
        value.add(sdk.otpApi.getTokenTimeStepValue(account))
        result.success(value)
    }

    fun getChallengeQuestionOtp(call: MethodCall, result: MethodChannel.Result) {
        val accountJson = call.argument<String>(ArgumentsConstants.ACCOUNT.value)
        val account = GsonUtil.fromJson(accountJson, Account::class.java)
        val answer = call.argument<String>(ArgumentsConstants.ANSWER.value)
        if (accountJson.isNullOrEmpty()) {
            result.error(
                SDKErrors.ERROR_NOT_ARGUMENTS.code,
                SDKErrors.ERROR_NOT_ARGUMENTS.message,
                SDKErrors.ERROR_NOT_ARGUMENTS.details
            )
            return
        }
        if (answer.isNullOrEmpty()) {
            result.error(
                SDKErrors.PARAMETER_MISSING.code,
                SDKErrors.PARAMETER_MISSING.message,
                SDKErrors.PARAMETER_MISSING.details
            )
            return
        }

        val serverCallback = object : OnServerParametersErrors {
            override fun onInvalidTimeStampLength(length: Int, reason: String) {
                Log.e("InvalidTimeStampLength", "onInvalidTimeStampLength $reason")
            }

            override fun onInvalidLengthToken(length: Int, reason: String) {
                Log.e("InvalidLengthToken", "onInvalidLengthToken $reason")
            }
        }

        val clientCallBack = object : OnClientArgumentsErrors {
            override fun onInvalidChallengeLength(length: Int, reason: String) {
                result.error(
                    SDKErrors.INVALID_CHALLENGE_LENGTH.code,
                    reason,
                    SDKErrors.INVALID_CHALLENGE_LENGTH.details
                )
            }

            override fun onMissingPassword(reason: String) {
                Log.e("MissingPassword", "onMissingPassword $reason")
            }
        }
        val data = sdk.challengeOtpApi.getChallengeQuestionOtp(
            account, answer, serverCallback, clientCallBack
        )
        return if (data.isEmpty || data.tokenValue.isNullOrEmpty()) {
            result.error(
                SDKErrors.PARAMETER_MISSING.code,
                SDKErrors.PARAMETER_MISSING.message,
                SDKErrors.PARAMETER_MISSING.details
            )
        } else {
            val value: MutableList<Any> = ArrayList(1)
            value.add(data.tokenValue)
            result.success(value)
        }
    }
}