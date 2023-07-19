package com.appgate.didsdk.constants

enum class SDKErrors(val code: String, val message: String, val details: String?) {
    DEFAULT_ERROR("99", "Unknown library error", null),
    ERROR_NOT_ARGUMENTS("99", "Missing arguments", null),
    ERROR_CHANNEL_METHOD("99", "Unknown method in this channel", null),
    INVALID_CHALLENGE_LENGTH("88", "onInvalidChallengeLength", null),
    PARAMETER_MISSING("98", "ErrorParameterMissing", null),
}