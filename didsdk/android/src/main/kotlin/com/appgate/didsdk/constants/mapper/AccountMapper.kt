package com.appgate.didsdk.constants.mapper

import com.appgate.didm_auth.common.account.entities.Account
import com.appgate.didsdk.constants.model.AccountDomain

class AccountMapper {

    fun mapFromModelSDK(model: Account): AccountDomain {
        return AccountDomain(
            model.username,
            model.organizationName,
            model.registrationDate,
            model.registrationMethod,
            model.isActivePushAuth,
            model.isActiveQRAuth,
            model.isActiveOTPAuth,
            model.isActivePushAlert,
            model.isActiveVoiceAuth,
            model.isActiveFaceAuth
        )
    }

    fun mapFromModelSDKList(accounts: List<Account>): List<AccountDomain> {
        return accounts.map { mapFromModelSDK(it) }
    }

}