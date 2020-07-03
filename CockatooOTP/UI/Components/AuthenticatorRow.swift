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
        VStack {
            if visible {
                HStack {
                    VStack(alignment: .leading) {
                        if account.type == "totp" {
                            Text(account.service!).lineLimit(1)
                        } else {
                            HStack {
                                Text(account.service!).lineLimit(1)
                                Button(action: {}) {
                                    Image(systemName: "arrow.counterclockwise")
                                }.onTapGesture {
                                    self.account.counter += 1
                                    do {
                                        try self.managedObjectContext.save()
                                    } catch {
                                        print("counter increment won't save")
                                    }

                                }

                            }
                        }
                        Spacer()
                        Text(account.account!).lineLimit(1)
                    }
                    Spacer()
                    Text(getOTP(account: account,
                                time: Int(timeManager.unixEpochTime)))
                        .font(.title)
                        .animation(.easeInOut)
                }
                if account.type == "totp" {
                    ProgressBar(progress: getProgress(time: timeManager.date.timeIntervalSince1970, interval: account.interval)).frame(height:10)
                } else {
                    Spacer().frame(height:10)
                }
                
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

func getOTP(account: Account, time: Int) -> String {
    guard let data = base32DecodeToData((account.key!.replacingOccurrences(of: " ", with: ""))) else {
        print(account.key!)
        return "Invalid key"

    }
    if account.interval <= 0 || account.digits <= 0 {
        return "Invalid interval"
    }
    
    if account.type == "totp" {
        guard let totp = TOTP(secret: data, digits: Int(account.digits), timeInterval:
            Int(account.interval)) else {
             return "Invalid key"
        }
        guard let otpString = totp.generate(secondsPast1970: time) else { return "Error" }
        return otpString
    } else {
        guard let hotp = HOTP(secret: data, digits: Int(account.digits)) else {
             return "Invalid key"
        }
        guard let otpString = hotp.generate(counter: UInt64(account.counter)) else { return "Error" }
        return otpString

    }
    
    
}

func getProgress(time: Double, interval:Int16) -> Float {
    if interval == 0 {
        return 0
    }
    return Float(Int(time) % Int(interval)) / Float(interval)
}

