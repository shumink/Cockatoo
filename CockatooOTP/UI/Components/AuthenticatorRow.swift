//
//  AuthenticatorRow.swift
//  Cockatoo
//
//  Created by Shumin Kong on 29/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI

struct AuthenticatorRow: View {
    var account: Account
//    var time: UInt64
    @EnvironmentObject var timeManager: TimeManager
    var body: some View {
        
        VStack {
            HStack {
                
                VStack(alignment: .leading) {
                    Text(account.service)
                    Spacer()
                    Text(account.account)
                    
                }
                Spacer()
                Text(account.getOTP(time: self.timeManager.unixEpochTime)).font(.title)

            }
            ProgressBar(progress: account.progress(time: timeManager.unixEpochTimeBinding))

        }.padding()
        .contextMenu {
            Button(action: {
                print("Favorite")
            }) {
                Text("Favorite")
            }

            Button(action: {
                print("Delete")
            }) {
                Text("Delete")
            }

            
        }
        
        
    }
    

}

struct AuthenticatorRow_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatorRow(account:accountData[1])
            .environmentObject(TimeManager())
    }
}

