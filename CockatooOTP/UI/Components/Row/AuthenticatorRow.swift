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
    private let nilTime = Date(timeIntervalSince1970: 0)
    @State var visible: Bool = true
    @State var border: Color = Color.gray
    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        VStack {
            if visible {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(account.service!).lineLimit(1)
                            if self.account.favTime != self.nilTime {
                                Image(systemName: "star.fill")
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
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "arrow.left")
                        }.onTapGesture {
                            if self.account.counter >= 0 {
                                self.account.counter -= 1
                            }
                            self.saveToDB(error:"counter increment won't save")
                        }.disabled(self.account.counter<=0)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "arrow.right")
                        }.onTapGesture {
                            self.account.counter += 1
                            self.saveToDB(error: "counter increment won't save")
                        }
                        Spacer()
                    }.frame(height:10)
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
                if self.account.favTime != self.nilTime {
                    self.account.favTime = self.nilTime
                } else {
                    self.account.favTime = Date()
                }
                
                self.saveToDB(error: "Favorite")
            }) {
                if self.account.favTime != self.nilTime {
                    Text("Unfavorite")
                } else {
                    Text("Favorite")
                }
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
    
    func saveToDB(error: String) {
        do {
            try self.managedObjectContext.save()
        } catch {
            print(error)
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
                
//                print(account)
                return "Invalid key"
        }
        guard let otpString = totp.generate(secondsPast1970: time) else { return "Error" }
        return otpString
    } else {
        guard let hotp = HOTP(secret: data, digits: Int(account.digits)) else {
//            print(account)
            return "Invalid key"
        }
        guard let otpString = hotp.generate(counter: UInt64(max(account.counter, 0))) else { return "Error" }
        return otpString
    }
}

func getProgress(time: Double, interval:Int16) -> Float {
    if interval == 0 {
        return 0
    }
    return Float(Int(time) % Int(interval)) / Float(interval)
}

