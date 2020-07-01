//
//  AccountsManager.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 1/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import Foundation
import os

func saveAccount(account: Account) {
//    let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(account, toFile: Account.ArchiveURL.path, secure)
//    let fullPath =
//    let randomFilename = UUID().uuidString
//    let fullPath = getDocumentsDirectory().appendingPathComponent(randomFilename)
    let randomFilename = UUID().uuidString
    let fullPath = getDocumentsDirectory().appendingPathComponent(randomFilename)

    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: account, requiringSecureCoding: true)
        try data.write(to: fullPath)
    } catch {
        os_log("Couldn't write file")
    }

}


func loadAccounts() -> [Account]? {
        do {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: somethingToSave, requiringSecureCoding: false)

            if let loadedAccounts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Account] {

        }
    } catch {
        os_log("Couldn't read file")

    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}
