//
//  AccountList.swift
//  Cockatoo
//
//  Created by Shumin Kong on 29/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
import CoreData

struct AuthenticatorList: View {
//    @FetchRequest(
//        entity: Account.entity(),
//                sortDescriptors: [
//                    NSSortDescriptor(keyPath: \Account.createdTime, ascending: false)
//                ],
//                predicate: NSPredicate(format: "service BEGINSWITH %@", "P")
//
//    ) var accounts: FetchedResults<Account>
//    var accounts: FetchedResults<Account>
//    @Binding var search:String
    var fetchRequest: FetchRequest<Account>
    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    init(search: String) {
        
        if search != "" {
            self.fetchRequest = FetchRequest<Account> (
                entity: Account.entity(),
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Account.createdTime, ascending: false)
                ],
                predicate: NSPredicate(format: "service CONTAINS %@", search)
            )
        } else {
            self.fetchRequest = FetchRequest<Account> (
                entity: Account.entity(),
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Account.createdTime, ascending: false)
                ]
            )
        }
    }
    
    var body: some View {
        List(fetchRequest.wrappedValue, id: \.id) { account in
            AuthenticatorRow(account: account)
            .onAppear(perform: {let _ = self.timeManager.updateTimer})
        }.onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
        })
    }
}

//struct AuthenticatorList_Previews: PreviewProvider {
//    static var previews: some View {
//        AuthenticatorList().environmentObject(TimeManager()).frame(minWidth: 360,
//        maxWidth:.infinity,
//        maxHeight: .infinity)
//    }
//}
