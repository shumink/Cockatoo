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
//    @FetchRequest(
//        entity: Account.entity(),
//                sortDescriptors: [
//                    NSSortDescriptor(keyPath: \Account.createdTime, ascending: false)
//                ]
//
//    ) var accounts: FetchedResults<Account>
    
//    var fetchRequest: FetchRequest<Account>
    
//    init() {
//        self.fetchRequest = FetchRequest<Account> (
//            entity: Account.entity(),
//            sortDescriptors: [
//                NSSortDescriptor(keyPath: \Account.createdTime, ascending: false)
//            ],
//            predicate: NSPredicate(format: "service BEGINSWITH %@", search)
//        )
//
//    }

    
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
