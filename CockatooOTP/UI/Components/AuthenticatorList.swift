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
    var fetchRequest: FetchRequest<Account>
    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    init(search: String) {
        self.fetchRequest = FetchRequest<Account> (
            entity: Account.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Account.favTime, ascending: false),
                NSSortDescriptor(keyPath: \Account.createdTime, ascending: false),
            ],
            predicate: search=="" ? nil: NSPredicate(format: "service CONTAINS %@", search)
        )

    }
    
    var body: some View {
        List(fetchRequest.wrappedValue, id: \.id) { account in
            AuthenticatorRow(account: account)
            .onAppear(perform: {let _ = self.timeManager.updateTimer})
        }
        .animation(.default)
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
        })
    }
}

struct AuthenticatorList_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


        return AuthenticatorList(search: "")
            .environmentObject(TimeManager())
            .environment(\.managedObjectContext, context)
    }
}
