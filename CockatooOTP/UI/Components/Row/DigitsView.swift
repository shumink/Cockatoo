//
//  DigitsView.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 7/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
import SwiftOTP

struct DigitsView: View {
    var account: Account
    let revealDuration = 20
    let saveToDB: (_ error: String) -> Void
    @Binding var revealTime: Date
    @EnvironmentObject var timeManager: TimeManager
    
    
    
    var body: some View {
        Text(getOTP(account: account,
                    time: Int(timeManager.unixEpochTime),
                    revealTime: self.revealTime))
            .font(.title)
            .animation(.easeInOut)
            .onTapGesture {
                print("tapped")
                if self.account.type == "hotp" && self.timeManager.date > self.revealTime {
                    self.revealTime = Date().addingTimeInterval(TimeInterval(self.revealDuration))
                    DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(self.revealDuration)) {
                        self.account.counter += 1
                        self.saveToDB("counter increment")
                    }
                }
            }
    }
}

//struct DigitsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DigitsView()
//    }
//}

func getOTP(account: Account, time: Int, revealTime: Date) -> String {
    switch account.type {
    case "totp":
        return getTOTP(account: account, time: time)
    case "hotp":
        return getHOTP(account: account, revealTime: revealTime)
    default:
        return "Invalid type"
    }
}

func getTOTP(account: Account, time: Int) -> String {
    guard let data = base32DecodeToData((account.key!.replacingOccurrences(of: " ", with: ""))) else {
        print(account.key!)
        return "Invalid key"

    }
    if account.interval <= 0 || account.digits <= 0 {
        return "Invalid interval"
    }
    
    guard let totp = TOTP(secret: data, digits: Int(account.digits), timeInterval: Int(account.interval)) else {
            return "Invalid key"
    }
    guard let otpString = totp.generate(secondsPast1970: time) else { return "Error" }
    return otpString

}

func getHOTP(account: Account, revealTime: Date) -> String {
    
    guard let data = base32DecodeToData((account.key!.replacingOccurrences(of: " ", with: ""))) else {
        print(account.key!)
        return "Invalid key"

    }

    
    guard let hotp = HOTP(secret: data, digits: Int(account.digits)) else {
        return "Invalid key"
    }
    
    guard Date() <= revealTime else {
        return String(repeating: "*", count: Int(account.digits))
    }
    
    guard let otpString = hotp.generate(counter: UInt64(max(account.counter, 0))) else { return "Error" }
    return otpString

}
