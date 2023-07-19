package com.appgate.didsdk.constants.model

data class AccountDomain(
    val username: String?,
    val organizationName: String?,
    val registrationDate: Long,
    val registrationMethod: Int,
    val activePushAuth: Boolean,
    val activeQRAuth: Boolean,
    val activeOTPAuth: Boolean,
    val activePushAlert: Boolean,
    val activeVoiceAuth: Boolean,
    val activeFaceAuth: Boolean
)
