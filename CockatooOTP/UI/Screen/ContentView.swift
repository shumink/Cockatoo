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
//    @State var accounts: [Account] = []
    // 1
//    @FetchRequest(
//      // 2
//        entity: Account.entity(),
//      // 3
//        sortDescriptors: [
//            NSSortDescriptor(keyPath: \Account.createdTime, ascending: false)
//        ]
//    // 4
//    ) var accounts: FetchedResults<Account>

    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        VStack {
            HeaderBar().environment(\.managedObjectContext, managedObjectContext)
            AuthenticatorList()

        }.frame(minWidth: 360,
           maxWidth: .infinity,
           minHeight: 720,
           maxHeight: .infinity)
//        .background(Color.white)
    }
    
//    func saveContext() {
//        do {
//            try managedObjectContext.save()
//        } catch {
//            print("Error saving managed object context: \(error)")
//        }
//    }
//    func addAccount(id: UUID, service: String, account: String, key: String, interval: Int,
//    digits: Int) {
//      // 1
//        let newAccount = Account(context: managedObjectContext)
//
//        // 2
////        (id, service, account, key, interval, digits)
////        newMovie.title = title
////        newMovie.genre = genre
////        newMovie.releaseDate = releaseDate
//        newAccount.id = id
//        newAccount.service = service
//        newAccount.account = account
//        newAccount.key = key
//        newAccount.interval = interval
//        newAccount.digits = digits
//        newAccount.createdTime = Date()
//        // 3
//        saveContext()
//    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TimeManager())
    }
}
