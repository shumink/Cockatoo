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
    let revealDuration: Double = 20
    @State var revealTime = Date.distantPast
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
                            Text(account.service ?? "").lineLimit(1)
                            if self.account.favTime != self.nilTime {
                                Image(systemName: "star.fill")
                            }
                        }
                        
                        Spacer()
                        Text(account.account ?? "").lineLimit(1)
                    }
                    Spacer()
                    DigitsView(account: account, saveToDB: self.saveToDB, revealTime: $revealTime)
                }
                ProgressBar(progress: self.progress).frame(height:10)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 1))
        .transition(.scale)
        .contextMenu {
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.account.favTime = self.account.favTime == self.nilTime ? Date(): self.nilTime
                        self.saveToDB(error: "Favorite")

                    }
                }
            }) {
                Text(self.account.favTime == self.nilTime ? "Favorite": "Unfavorite")
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.visible.toggle()
                        withAnimation {
                            self.managedObjectContext.delete(self.account)

                        }
                        self.saveToDB(error: "delete")
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
    var progress: Double {
        switch account.type {
        case "totp":
            return getTOTPProgress(time: timeManager.date.timeIntervalSince1970, interval: Int(account.interval))
        case "hotp":
            let pg = 1 - min(1, max(0, Double((revealTime.timeIntervalSince1970 - timeManager.date.timeIntervalSince1970) / self.revealDuration)))
            
            return pg == 1 ? 0 : pg
        case .none:
            return 0
        case .some(_):
            return 0
        }
    }
}


func getTOTPProgress(time: Double, interval:Int) -> Double {
    if interval == 0 || time == 0 {
        return 0
    }
    
    let multiples = Int(time) / interval
    return (time - Double((interval * multiples))) / Double(interval)
}

struct AuthenticatorRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return AuthenticatorList(search: "").environmentObject(TimeManager())
        .environment(\.managedObjectContext, context)

    }
}
