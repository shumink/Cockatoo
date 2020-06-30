//
//  ManualView.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 30/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
import Combine


struct ManualView: View {
    @State var service: String = ""
    @State var account: String = ""
    @State var key: String = ""
    @State var interval: String = ""
    @State var digits: String = ""
    
    
    func save()  {
        if self.interval == "" {
            self.interval = "30"
        }
        
        if self.digits == "" {
            self.digits = "6"
        }
        
        let newAccount = Account(service: service, account: account, key: key, interval: Int(interval)!, digits: Int(digits)!)
        accountData.append(newAccount) 

    }

    var body: some View {
        NavigationView {
        
            Form {
                Section (header:Text("Your Account Information")) {
                    TextField("Service", text: $service)
                    TextField("Account", text: $account)
                    SecureField("Secret Key", text: $key)
                }
                Section (header:Text("Advance")) {
                    TextField("Interval", text: $interval)
                        .keyboardType(.numberPad)
                        .onReceive(Just(interval)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.interval = filtered
                                }
                        }
                    TextField("Digits", text: $digits)
                        .keyboardType(.numberPad)
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
                    }

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
