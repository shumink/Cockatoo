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

struct ManualView: View {
    @State var service: String = ""
    @State var account: String = ""
    @State var key: String = ""
    @State var interval: String = ""
    @State var digits: String = ""
    @State var warning: String = ""
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let invalidKeyWarning: String = "Your secret key is invalid."
    
    var canSave: Bool {
        return service != "" &&
            account != "" &&
            key != "" &&
            interval != "" &&
            digits != "" &&
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
        newAccount.digits = Int16(digits)!
        newAccount.createdTime = Date()
        // 3
        do {
            try managedObjectContext.save()
            print("saved")
        } catch {
            print("Error saving managed object context: \(error)")
        }
//        
//        let newAccount = Account(service: service, account: account, key: key, interval: Int(interval)!, digits: Int(digits)!)
//        accountData.append(newAccount) 

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
                }
                Section (header:Text("Advance")) {
                    TextField("Interval", text: $interval)
//                        .keyboardType(.numberPad)
                        .onReceive(Just(interval)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.interval = filtered
                                }
                        }
                    TextField("Digits", text: $digits)
//                        .keyboardType(.numberPad)
                        .onReceive(Just(digits)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.digits = filtered
                                }
                        }


                }
                Section {
                    Button(action: self.save) {
                        Text("Save")
                    }.disabled(!canSave)

                }
            }
        }
    }
}

struct ManualView_Previews: PreviewProvider {
    static var previews: some View {
        ManualView()
    }
}
