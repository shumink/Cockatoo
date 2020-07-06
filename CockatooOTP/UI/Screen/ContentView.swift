//
//  ContentView.swift
//  Cockatoo
//
//  Created by Shumin Kong on 29/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import CoreData
import SwiftUI


struct ContentView: View {
    @State var search:String = ""    
    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext
        
    var body: some View {
        VStack {
            HeaderBar(search: $search).environment(\.managedObjectContext, managedObjectContext)
            AuthenticatorList(search: search)

        }.frame(minWidth: 360,
           maxWidth: .infinity,
           minHeight: 720,
           maxHeight: .infinity)
    }
}
