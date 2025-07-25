package com.appgate.didsdk.constants

enum class DIDModulesNames(val value: String) {
    DID_REGISTRATION_WITH_URL("didRegistrationWithUrl"),
    DID_REGISTRATION_BY_QRCODE("didRegistrationByQRCode"),
    EXIST_ACCOUNTS("existAccounts"),
    GET_ACCOUNTS("getAccounts"),
    PUSH_TRANSACTION_OPEN_LISTENER("setPushTransactionOpenListener"),
    PUSH_ALERT_OPEN_LISTENER("setPushAlertOpenListener"),
    CONFIRM_PUSH_TRANSACTION_ACTION("confirmPushTransactionAction"),
    DECLINE_PUSH_TRANSACTION_ACTION("declinePushTransactionAction"),
    APPROVED_PUSH_ALERT_ACTION("approvePushAlertAction"),
    QR_AUTHENTICATION_PROCESS("qrAuthenticationProcess"),
    CONFIRM_QRCODE_TRANSACTION_ACTION("confirmQRCodeTransactionAction"),
    DECLINE_QRCODE_TRANSACTION_ACTION("declineQRCodeTransactionAction"),
    SET_ACCOUNT_USERNAME("setAccountUsername"),
    SET_APPLICATION_NAME("setApplicationName"),
    REMOVE_ACCOUNT("removeAccount"),
    UPDATE_GLOBAL_CONFIG("updateGlobalConfig"),
    GET_MASKED_APP_INSTANCE_ID("getMaskedAppInstanceID"),
    GET_MOBILE_ID("getMobileID"),
    GET_TOKEN_VALUE("getTokenValue"),
    GET_TOKEN_TIME_STEP_VALUE("getTokenTimeStepValue"),
    GET_CHALLENGE_QUESTION_OTP("getChallengeQuestionOtp"),

}