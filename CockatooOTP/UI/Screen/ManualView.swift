//
//  ManualView.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 30/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
import Combine
import SwiftOTP
import CoreData
import os

struct ManualView: View {
    @State var timeBased = true
    @State var service: String = ""
    @State var account: String = ""
    @State var key: String = ""
    @State var interval: String = "30"
    @State var digits: String = "6"
    @State var counter: String = "0"
    @State var warning: String = ""
    @Environment(\.managedObjectContext) var managedObjectContext
    var callback: () -> Void
    
    let invalidKeyWarning: String = "Your secret key is invalid."
    
    var canSave: Bool {
        return service != "" &&
            account != "" &&
            key != "" &&
            interval != "" &&
            Int(interval) != nil &&
            Int(interval) ?? 0 > 0 &&
            digits != "" &&
            Int(digits) != nil &&
            Int(digits) ?? 0 > 0 &&
            Int(digits) ?? 10 < 10  &&
            warning == ""
    }
    
    func save()  {
        if self.interval == "" {
            self.interval = "30"
        }
        
        if self.digits == "" {
            self.digits = "6"
        }
        
        let newAccount = Account(context: managedObjectContext)
        newAccount.id = UUID()
        newAccount.service = service
        newAccount.account = account
        newAccount.key = key
        newAccount.interval = Int16(interval)!
        newAccount.type = self.timeBased ? "totp" : "hotp"
        newAccount.digits = Int16(digits)!
        newAccount.counter = Int64(counter)!
        newAccount.createdTime = Date()
        newAccount.favTime = Date(timeIntervalSince1970: 0)
        do {
            
            try managedObjectContext.save()
        } catch (let error) {
            os_log("Error saving managed object context: %s", error.localizedDescription)
        }
        callback()

    }

    var body: some View {
        NavigationView {
        
            Form {
                Section (header:Text("Your Account Information"), footer: Text(warning).foregroundColor(Color.red)) {
                    TextField("Service", text: $service)
                    TextField("Account", text: $account)
                    SecureField("Secret Key", text: $key)
                    .onReceive(Just(key)) { newValue in
                        let data = base32DecodeToData(newValue.replacingOccurrences(of: " ", with: ""))
                        if data == nil {
                            self.warning = self.invalidKeyWarning
                        } else {
                            self.warning = ""
                            self.key = newValue
                        }
                    }
                    Toggle(isOn: $timeBased) {
                        Text("Time-based")
                    }

                }
                
                // Harcoding this section
//                Section (header:Text("Advanced")) {
//                    Toggle(isOn: $timeBased) {
//                        Text("Time-based")
//                    }
//                    if self.timeBased {
//                        TextField("Interval", text: $interval)
//                            .onReceive(Just(interval)) { newValue in
//                                    let filtered = newValue.filter { "0123456789".contains($0) }
//                                    if filtered != newValue {
//                                        self.interval = filtered
//                                    }
//                            }
//                    } else {
//                        TextField("Counter", text: $counter)
//                            .onReceive(Just(counter)) { newValue in
//                                    let filtered = newValue.filter { "0123456789".contains($0) }
//                                    if filtered != newValue {
//                                        self.counter = filtered
//                                    }
//                            }
//
//                    }
//                    TextField("Digits", text: $digits)
//                        .onReceive(Just(digits)) { newValue in
//                                let filtered = newValue.filter { "0123456789".contains($0) }
//                                if filtered != newValue {
//                                    self.digits = filtered
//                                }
//                        }
//                }
                Section {
                    Button(action: self.save) {
                        Text("Save")
                    }.disabled(!canSave)

                }
            }.navigationBarTitle("Manual", displayMode: .inline)
        }.navigationViewStyle(StackNavigationViewStyle())
        
    }
}

struct ManualView_Previews: PreviewProvider {
    static var previews: some View {
        ManualView(callback: {})
    }
}
