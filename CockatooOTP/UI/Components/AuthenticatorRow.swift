//
//  AuthenticatorRow.swift
//  Cockatoo
//
//  Created by Shumin Kong on 29/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import CoreData
import SwiftUI
import SwiftOTP

struct AuthenticatorRow: View {
    var account: Account
//    var time: UInt64
    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        
        VStack {
            HStack {
                
                VStack(alignment: .leading) {
//                    Text(account.service)
                    account.service.map(Text.init)
                    Spacer()
//                    Text(account.account)
                    account.account.map(Text.init)
                    
                }
                Spacer()
                Text(getOTP(key: account.key!,
                            interval: account.interval,
                            digits: account.digits,
                            time: Int(timeManager.unixEpochTime)))
                    .font(.title)

            }
            ProgressBar(progress: getProgress(time: timeManager.date.timeIntervalSince1970, interval: account.interval))

        }.padding()
        .contextMenu {
            Button(action: {
                print("Favorite")
            }) {
                Text("Favorite")
            }

            Button(action: {
                print("Delete")
                self.managedObjectContext.delete(self.account)
                
            }) {
                Text("Delete")
            }
        }
    }
}

func getOTP(key:String, interval: Int16, digits: Int16, time: Int) -> String {
    guard let data = base32DecodeToData(key.replacingOccurrences(of: " ", with: "")) else {
        print(key)
        return "Invalid key"

    }
    
    guard let totp = TOTP(secret: data, digits: Int(digits), timeInterval:
        Int(interval)) else {
         return "Invalid key"
    }
    guard let otpString = totp.generate(secondsPast1970: time) else { return "Error" }
    return otpString
    
}

func getProgress(time: Double, interval:Int16) -> Float {
//    let multiplies = Int(time) / (Int(time) % Int(interval))
//    return Float(time - Double(multiplies * Int(interval)))
    return Float(Int(time) % Int(interval)) / Float(interval)
}

