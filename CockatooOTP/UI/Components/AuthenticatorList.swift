//
//  AccountList.swift
//  Cockatoo
//
//  Created by Shumin Kong on 29/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI

struct AuthenticatorList: View {
    
    @EnvironmentObject var timeManager: TimeManager
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(accountData, id: \.id) { account in
                    AuthenticatorRow(account: account)
                    .border(Color.gray)
                    .onAppear(perform: {let _ = self.timeManager.updateTimer})
                }
            }.padding()
        }
    }
}

struct AuthenticatorList_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatorList().environmentObject(TimeManager()).frame(minWidth: 360,
        maxWidth:.infinity,
        maxHeight: .infinity)
    }
}
