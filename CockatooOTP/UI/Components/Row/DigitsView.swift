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
    @State var copied: Bool = false
    @Binding var revealTime: Date
    @EnvironmentObject var timeManager: TimeManager
    var masked:Bool {
        self.account.type == "hotp" && self.timeManager.date > self.revealTime
    }
    
    var timeUntilNextToken: Int {
        switch self.account.type {
        case "totp":
            return Int(self.account.interval) - Int(self.timeManager.date.timeIntervalSince1970) % Int(self.account.interval)
        case "hotp":
            return Int(self.revealTime.timeIntervalSince1970 - self.timeManager.date.timeIntervalSince1970)

        default:
            return 0
        }
    }
    
    
    var body: some View {
        
        HStack {
            if copied {
                Image(systemName: "checkmark")
                .transition(.scale)
                .animation(.linear)
            } else {
                Image(systemName: "doc.on.doc")
                    .transition(.scale)
                    .animation(.linear)
                    .disabled(self.masked)
                    .onTapGesture {
                        if self.masked {
                            self.reveal()
                        }
                        UIPasteboard.general.string = getOTP(account: self.account, time: Int(self.timeManager.unixEpochTime),
                        revealTime: self.revealTime)
                        withAnimation {
                            self.copied.toggle()
                        }

                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(min(3, self.timeUntilNextToken)) ) {
                            withAnimation {
                                self.copied.toggle()
                            }
                        }
                    }
            }
                        
            Text(getOTP(account: account,
                        time: Int(timeManager.unixEpochTime),
                        revealTime: self.revealTime))
                .font(Font.system(.title, design: .monospaced))
                .onTapGesture {
                    if self.masked {
                        self.reveal()
                    }
                }

        }
    }
    
    func reveal() {
        self.revealTime = Date().addingTimeInterval(TimeInterval(self.revealDuration))
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(self.revealDuration)) {
            self.account.counter += 1
            self.saveToDB("counter increment")
        }
    }
}

struct DigitsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let acc1 = Account(context: context)
        acc1.account = "shuminkong@protonmail.com"
        acc1.service = "Protonmail"
        acc1.digits = 6
        acc1.interval = 30
        acc1.type = "totp"
        acc1.key = "AWSGRJH7572OE3KJZEM4SNDVHD57DKDGQQ7JYWEZR5ZWOXAFJCOJDI5D"
        acc1.favTime = Date(timeIntervalSince1970: 0)
        acc1.createdTime = Date(timeIntervalSince1970: 0)
        acc1.counter = 0
        
        let acc2 = Account(context: context)
        acc2.account = "shuminkong@protonmail.com"
        acc2.service = "Protonmail"
        acc2.digits = 6
        acc2.interval = 30
        acc2.type = "totp"
        acc2.key = "jcxjomietvmuwnvm4nbllhmli6k55xjjf74xf2apzm7z2rvayfrsycvi"
        acc2.favTime = Date(timeIntervalSince1970: 0)
        acc2.createdTime = Date(timeIntervalSince1970: 0)
        acc2.counter = 0
        //
        //        do {
        //            try context.save()
        //        } catch {
        //            let nserror = error as NSError
        //            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        //        }

        return AuthenticatorList(search: "").environmentObject(TimeManager())
        .environment(\.managedObjectContext, context)
        
    }
}

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
