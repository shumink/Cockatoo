//
//  AuthenticatorView.swift
//  Cockatoo
//
//  Created by Shumin Kong on 30/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI

struct AuthenticatorView: View {
    var account: Account
    @EnvironmentObject var timeManager: TimeManager

    var body: some View {
        VStack {
            Text(account.service)
            Text(account.account)
            Text(account.getOTP(time: self.timeManager.unixEpochTime)).font(.title)
            ProgressBar(progress: account.progress(time: timeManager.unixEpochTimeBinding))
            
        }.frame(minWidth: 360, maxWidth: .infinity, maxHeight: .infinity)
    }
}

