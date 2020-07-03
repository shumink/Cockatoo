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
    @State var visible: Bool = true
    @State var border: Color = Color.gray
    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
//        Divider()
//        if visible {
        VStack {
            
            if visible {
                HStack {
                    VStack(alignment: .leading) {
                        Text(account.service!).lineLimit(1)
                        Spacer()
                        Text(account.account!).lineLimit(1)
                    }
                    Spacer()
                    Text(getOTP(key: account.key!,
                                interval: account.interval,
                                digits: account.digits,
                                time: Int(timeManager.unixEpochTime)))
                        .font(.title)
                        
                }
                ProgressBar(progress: getProgress(time: timeManager.date.timeIntervalSince1970, interval: account.interval)).frame(height:10)
            }

        }
        .animation(.easeInOut)
        .transition(.opacity)
        .padding()
        .border(Color.gray)

        .contextMenu {
            Button(action: {
                print("Favorite")
            }) {
                Text("Favorite")
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.visible.toggle()
                        self.managedObjectContext.delete(self.account)
                   }

                }

                
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
    if interval <= 0 || digits <= 0 {
        return "Invalid interval"
    }
    guard let totp = TOTP(secret: data, digits: Int(digits), timeInterval:
        Int(interval)) else {
         return "Invalid key"
    }
    
    
    guard let otpString = totp.generate(secondsPast1970: time) else { return "Error" }
    return otpString
    
}

func getProgress(time: Double, interval:Int16) -> Float {
    if interval == 0 {
        return 0
    }
    return Float(Int(time) % Int(interval)) / Float(interval)
}

