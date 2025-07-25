package com.appgate.didsdk

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.appgate.appgate_sdk.data.device.provider.PushNotificationProvider
import com.appgate.appgate_sdk.data.utils.GsonUtil
import com.appgate.didm_auth.DetectID
import com.appgate.didm_auth.common.transaction.TransactionInfo
import com.appgate.didsdk.constants.mapper.TransactionInfoMapper
import com.appgate.didsdk.modules.PushModule

class DIDFCMService(private val context: Context) {

    fun onMessageReceived(data: Map<String, String>) {
        if (data.isNotEmpty() && DetectID.sdk(context).isValidPayload(data)) {
            DetectID.sdk(context).getPushApi().setPushAlertReceivedListener {
                clearNotification(context, getNotificationId(it))
                Handler(Looper.getMainLooper()).postDelayed({
                    prepareFlutterNotificationFromDID(it, 0, context)
                }, 100)
            }
            DetectID.sdk(context).getPushApi().setPushTransactionReceivedListener {
                clearNotification(context, getNotificationId(it))
                Handler(Looper.getMainLooper()).postDelayed({
                    prepareFlutterNotificationFromDID(it, 1, context)
                }, 100)
            }
            DetectID.sdk(context).subscribePayload(data)
        }
    }

    fun onNewToken(newToken: String, pushNotificationProvider: PushNotificationProvider) {
        DetectID.sdk(context).receivePushServiceId(newToken, pushNotificationProvider)
    }

    private fun clearNotification(context: Context, id: Int) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(id)
    }

    private fun prepareFlutterNotificationFromDID(
        transactionInfo: TransactionInfo,
        typeTransaction: Int,
        context: Context
    ) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val extras = Bundle()
        extras.putString(
            PushModule.FT_TRANSACTION_INFO,
            GsonUtil.toJson(TransactionInfoMapper().mapFromModelSDK(transactionInfo))
        )
        extras.putInt(PushModule.FT_TYPE_PUSH, typeTransaction)

        val packageName = context.packageName
        val packageManager = context.packageManager

        val appInfo = packageManager.getApplicationInfo(context.packageName, 0)
        val appIconResId = appInfo.icon

        val launchIntentForPackage = packageManager.getLaunchIntentForPackage(packageName)
        launchIntentForPackage!!.putExtras(extras)
        launchIntentForPackage.flags =
            Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP


        val notificationId = getNotificationId(transactionInfo)
        val pendingIntent = PendingIntent.getActivity(
            context, notificationId, launchIntentForPackage,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val notificationBuilder = NotificationCompat.Builder(context, "EasySol_Channel")
            .setContentTitle(transactionInfo.subject)
            .setContentText(transactionInfo.message)
            .setSmallIcon(appIconResId)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setExtras(extras)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel = NotificationChannel(
                "EasySol_Channel",
                "EasySolPush",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(notificationChannel)
        }
        notificationManager.notify(notificationId, notificationBuilder.build())
    }

    private fun getNotificationId(transactionInfo: TransactionInfo): Int {
        var notificationId = System.currentTimeMillis().toInt()
        try {
            notificationId = transactionInfo.timeStamp.toInt()
        } catch (e1: Exception) {
            Log.e("", "${e1.message}")

        }
        return notificationId
    }
}