//
//  ContentView.swift
//  Cockatoo
//
//  Created by Shumin Kong on 29/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timeManager: TimeManager
    var body: some View {
        VStack {
            HeaderBar()
            AuthenticatorList()

        }.frame(minWidth: 360,
           maxWidth: .infinity,
           minHeight: 720,
           maxHeight: .infinity)
//        .background(Color.white)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TimeManager())
    }
}
