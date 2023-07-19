package com.appgate.didsdk

import com.appgate.didsdk.constants.DIDMethodChannelNames
import com.appgate.didsdk.util.DIDPushUtil
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


open class DIDMainActivity : FlutterActivity() {

    open fun getTokenHMS() {}
    open fun getTokenFirebase() {}

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, DIDMethodChannelNames.PUSH_MODULE.value
        )
        DIDPushUtil().getExtrasSendData(methodChannel, intent)
        getTokenFirebase()
        getTokenHMS()
    }


}
