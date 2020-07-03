//
//  SettingView.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 3/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationView {
                Form {
                Section {
                    Text("Hello World")
                }
            }.navigationBarTitle("Settings", displayMode: .inline)

        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
