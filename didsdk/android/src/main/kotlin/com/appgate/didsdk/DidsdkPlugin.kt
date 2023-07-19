package com.appgate.didsdk

import android.content.Context
import android.content.Intent
import android.util.Log
import com.appgate.appgate_sdk.data.utils.GsonUtil
import com.appgate.appgate_sdk.encryptor.exceptions.SDKException
import com.appgate.didm_auth.DetectID
import com.appgate.didm_auth.common.handler.EnrollmentResultHandler
import com.appgate.didsdk.constants.ArgumentsConstants
import com.appgate.didsdk.constants.DIDMethodChannelNames.ACCOUNTS_MODULE
import com.appgate.didsdk.constants.DIDMethodChannelNames.DID_SDK
import com.appgate.didsdk.constants.DIDMethodChannelNames.OTP_MODULE
import com.appgate.didsdk.constants.DIDMethodChannelNames.PUSH_MODULE
import com.appgate.didsdk.constants.DIDMethodChannelNames.QR_MODULE
import com.appgate.didsdk.constants.DIDModulesNames.APPROVED_PUSH_ALERT_ACTION
import com.appgate.didsdk.constants.DIDModulesNames.CONFIRM_PUSH_TRANSACTION_ACTION
import com.appgate.didsdk.constants.DIDModulesNames.CONFIRM_QRCODE_TRANSACTION_ACTION
import com.appgate.didsdk.constants.DIDModulesNames.DECLINE_PUSH_TRANSACTION_ACTION
import com.appgate.didsdk.constants.DIDModulesNames.DECLINE_QRCODE_TRANSACTION_ACTION
import com.appgate.didsdk.constants.DIDModulesNames.DID_REGISTRATION_BY_QRCODE
import com.appgate.didsdk.constants.DIDModulesNames.DID_REGISTRATION_WITH_URL
import com.appgate.didsdk.constants.DIDModulesNames.EXIST_ACCOUNTS
import com.appgate.didsdk.constants.DIDModulesNames.GET_ACCOUNTS
import com.appgate.didsdk.constants.DIDModulesNames.GET_CHALLENGE_QUESTION_OTP
import com.appgate.didsdk.constants.DIDModulesNames.GET_DEVICE_ID
import com.appgate.didsdk.constants.DIDModulesNames.GET_MASKED_APP_INSTANCE_ID
import com.appgate.didsdk.constants.DIDModulesNames.GET_MOBILE_ID
import com.appgate.didsdk.constants.DIDModulesNames.GET_TOKEN_TIME_STEP_VALUE
import com.appgate.didsdk.constants.DIDModulesNames.GET_TOKEN_VALUE
import com.appgate.didsdk.constants.DIDModulesNames.PUSH_ALERT_OPEN_LISTENER
import com.appgate.didsdk.constants.DIDModulesNames.PUSH_TRANSACTION_OPEN_LISTENER
import com.appgate.didsdk.constants.DIDModulesNames.QR_AUTHENTICATION_PROCESS
import com.appgate.didsdk.constants.DIDModulesNames.REMOVE_ACCOUNT
import com.appgate.didsdk.constants.DIDModulesNames.SET_ACCOUNT_USERNAME
import com.appgate.didsdk.constants.DIDModulesNames.SET_APPLICATION_NAME
import com.appgate.didsdk.constants.DIDModulesNames.UPDATE_GLOBAL_CONFIG
import com.appgate.didsdk.constants.SDKErrors.ERROR_CHANNEL_METHOD
import com.appgate.didsdk.constants.SDKErrors.ERROR_NOT_ARGUMENTS
import com.appgate.didsdk.constants.model.TransactionInfoDomain
import com.appgate.didsdk.modules.AccountsModule
import com.appgate.didsdk.modules.OTPModule
import com.appgate.didsdk.modules.PushModule
import com.appgate.didsdk.modules.PushModule.Companion.FT_TRANSACTION_INFO
import com.appgate.didsdk.modules.PushModule.Companion.FT_TYPE_PUSH
import com.appgate.didsdk.modules.QRModule
import com.appgate.didsdk.util.DIDPushUtil
import com.appgate.didsdk.util.DIDTypePush
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.NewIntentListener

/** DidsdkPlugin */
class DidsdkPlugin : MethodCallHandler, NewIntentListener, FlutterPlugin, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var registerChannel: MethodChannel
    private lateinit var accountsChannel: MethodChannel
    private lateinit var qrChannel: MethodChannel
    private lateinit var otpChannel: MethodChannel
    private lateinit var pushChannel: MethodChannel
    private lateinit var sdk: DetectID
    private var context: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        registerChannel = MethodChannel(flutterPluginBinding.binaryMessenger, DID_SDK.value)
        registerChannel.setMethodCallHandler(this)

        accountsChannel = MethodChannel(flutterPluginBinding.binaryMessenger, ACCOUNTS_MODULE.value)
        accountsChannel.setMethodCallHandler(this)

        qrChannel = MethodChannel(flutterPluginBinding.binaryMessenger, QR_MODULE.value)
        qrChannel.setMethodCallHandler(this)

        otpChannel = MethodChannel(flutterPluginBinding.binaryMessenger, OTP_MODULE.value)
        otpChannel.setMethodCallHandler(this)

        pushChannel = MethodChannel(flutterPluginBinding.binaryMessenger, PUSH_MODULE.value)
        pushChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val accountsModule = AccountsModule(context)
        val qrModule = QRModule(context)
        val otpModule = OTPModule(context)
        val pushModule = PushModule(context, pushChannel)

        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            DID_REGISTRATION_WITH_URL.value -> {
                didRegistrationWithUrl(call, result)
            }

            DID_REGISTRATION_BY_QRCODE.value -> {
                didRegistrationByQRCode(call, result)
            }

            EXIST_ACCOUNTS.value -> {
                accountsModule.existAccounts(result)
            }

            GET_ACCOUNTS.value -> {
                accountsModule.getAccounts(result)
            }

            PUSH_TRANSACTION_OPEN_LISTENER.value -> {
                pushModule.setPushTransactionOpenListener(result)
            }

            PUSH_ALERT_OPEN_LISTENER.value -> {
                pushModule.setPushAlertOpenListener(result)
            }

            CONFIRM_PUSH_TRANSACTION_ACTION.value -> {
                pushModule.confirmOrDecline(true, call, result)
            }

            DECLINE_PUSH_TRANSACTION_ACTION.value -> {
                pushModule.confirmOrDecline(false, call, result)
            }

            APPROVED_PUSH_ALERT_ACTION.value -> {
                pushModule.approvePush(call, result)
            }

            QR_AUTHENTICATION_PROCESS.value -> {
                qrModule.qrAuthenticationProcess(call, result)
            }

            CONFIRM_QRCODE_TRANSACTION_ACTION.value -> {
                qrModule.confirmOrDecline(true, call, result)
            }

            DECLINE_QRCODE_TRANSACTION_ACTION.value -> {
                qrModule.confirmOrDecline(false, call, result)
            }

            SET_ACCOUNT_USERNAME.value -> {
                accountsModule.setAccountUsername(call, result)
            }

            SET_APPLICATION_NAME.value -> {
                setApplicationName(call, result)
            }

            REMOVE_ACCOUNT.value -> {
                accountsModule.removeAccount(call, result)
            }

            UPDATE_GLOBAL_CONFIG.value -> {
                accountsModule.updateGlobalConfig(call, result)
            }

            GET_DEVICE_ID.value -> {
                getDeviceID(result)
            }

            GET_MASKED_APP_INSTANCE_ID.value -> {
                getMaskedAppInstanceID(result)
            }

            GET_MOBILE_ID.value -> {
                getMobileID(result)
            }

            GET_TOKEN_VALUE.value -> {
                otpModule.getTokenValue(call, result)
            }

            GET_TOKEN_TIME_STEP_VALUE.value -> {
                otpModule.getTokenTimeStepValue(call, result)
            }

            GET_CHALLENGE_QUESTION_OTP.value -> {
                otpModule.getChallengeQuestionOtp(call, result)
            }

            else -> {
                result.error(
                    ERROR_CHANNEL_METHOD.code,
                    ERROR_CHANNEL_METHOD.message,
                    ERROR_CHANNEL_METHOD.details
                )
            }
        }


    }

    private fun didRegistrationByQRCode(call: MethodCall, result: Result) {
        val url = call.argument<String>(ArgumentsConstants.URL.value)
        val code = call.argument<String>(ArgumentsConstants.CODE.value)
        if (code.isNullOrEmpty())
            result.error(
                ERROR_NOT_ARGUMENTS.code, ERROR_NOT_ARGUMENTS.message, ERROR_NOT_ARGUMENTS.details
            )

        DetectID.sdk(context)
            .didRegistrationByQRCode(code!!, url!!, object : EnrollmentResultHandler {
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
            })

    }

    private fun didRegistrationWithUrl(call: MethodCall, result: Result) {
        val url = call.argument<String>(ArgumentsConstants.URL.value)
        if (url.isNullOrEmpty())
            result.error(
                ERROR_NOT_ARGUMENTS.code,
                ERROR_NOT_ARGUMENTS.message,
                ERROR_NOT_ARGUMENTS.details
            )

        DetectID.sdk(context).didRegistration(url!!, object : EnrollmentResultHandler {
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
        })

    }

    private fun setApplicationName(call: MethodCall, result: Result) {
        val name = call.argument<String>(ArgumentsConstants.NAME.value)
        if (name.isNullOrEmpty())
            result.error(
                ERROR_NOT_ARGUMENTS.code, ERROR_NOT_ARGUMENTS.message, ERROR_NOT_ARGUMENTS.details
            )

        DetectID.sdk(context).setApplicationName(name)
        val value: MutableList<String> = ArrayList(1)
        value.add("")
        result.success(value)

    }

    private fun getDeviceID(result: Result) {
        val value: MutableList<String> = ArrayList(1)
        value.add(DetectID.sdk(context).deviceID)
        result.success(value)
    }

    private fun getMaskedAppInstanceID(result: Result) {
        val value: MutableList<String> = ArrayList(1)
        value.add(DetectID.sdk(context).maskedAppInstanceID)
        result.success(value)
    }

    private fun getMobileID(result: Result) {
        val value: MutableList<String> = ArrayList(1)
        value.add(DetectID.sdk(context).mobileID)
        result.success(value)
    }

    private fun initDID() {
        this.sdk = DetectID.sdk(context)
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        registerChannel.setMethodCallHandler(null)
        accountsChannel.setMethodCallHandler(null)
        qrChannel.setMethodCallHandler(null)
        otpChannel.setMethodCallHandler(null)
        pushChannel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        this.context = binding.activity
        this.initDID()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        this.context = binding.activity
        this.initDID()
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onDetachedFromActivity() {}

    override fun onNewIntent(intent: Intent): Boolean {
        DIDPushUtil().getExtrasSendData(pushChannel,intent)
        return true
    }

    companion object {
        private var TAG = DidsdkPlugin::class.java.simpleName

    }


}
