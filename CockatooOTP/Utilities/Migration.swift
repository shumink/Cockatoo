//
//  Migration.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 7/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import Foundation
import CoreData
import SwiftOTP

func importFromGoogleAuth(code: String, moc: NSManagedObjectContext) -> Int {
    let migratedAccounts = deserialize(code: code)
    migratedAccounts.forEach { otpParams in
        immigrate(otp: otpParams, moc: moc)
    }
    do {
        try moc.save()
        return migratedAccounts.count
    } catch (let e) {
        print(e)
        return 0
    }
    
}

func exportToGoogleAuth(accounts: [Account]) throws -> String {
    
    let otpParams = accounts.map(emigrate)
    
    let result = MigrationPayload.with {
        $0.otpParameters = otpParams
        $0.batchSize = Int32(otpParams.count)
        $0.batchIndex = 0
        $0.batchID = 0

    }
    
    let data = try result.serializedData()
    return Data(data).base64EncodedString()    
}




func deserialize(code: String) -> [MigrationPayload.OtpParameters] {
    let decoded = Data(base64Encoded: code)!
    do {
        let migration = try MigrationPayload(serializedData: decoded)
        print(migration.otpParameters)

        return migration.otpParameters
    } catch (let e) {
        print(e)
        return []
    }
}

func immigrate(otp: MigrationPayload.OtpParameters, moc: NSManagedObjectContext) {
    let newAccount = Account(context: moc)
    newAccount.id = UUID()
    newAccount.service = otp.issuer
    newAccount.account = otp.name
    newAccount.key = base32Encode(otp.secret)
    newAccount.interval = Int16(30)
    newAccount.type = (otp.type == MigrationPayload.OtpType.otpTotp ? "totp": "hotp")
    newAccount.digits = 6
    newAccount.counter = Int64(otp.counter)
    newAccount.createdTime = Date()
    newAccount.favTime = Date(timeIntervalSince1970: 0)
    
    if newAccount.service == "" && newAccount.account!.contains(":") {
        newAccount.service = String(newAccount.account!.split(separator: ":")[0])
        newAccount.account = String(newAccount.account!.split(separator: ":")[1])
    }
}

func emigrate(account: Account) -> MigrationPayload.OtpParameters {
    var otp = MigrationPayload.OtpParameters()
    otp.issuer = account.service!
    otp.name = account.account!
    otp.secret = base32DecodeToData(account.key!)!
    otp.type = account.type == "totp" ? MigrationPayload.OtpType.otpTotp: MigrationPayload.OtpType.otpHotp
    otp.digits = Int32(account.digits)
    otp.counter = account.counter
    return otp
}
