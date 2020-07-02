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
    @FetchRequest(
      // 2
        entity: Account.entity(),
      // 3
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Account.createdTime, ascending: false)
        ]
    // 4
    ) var accounts: FetchedResults<Account>

    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(accounts, id: \.id) { account in
                    AuthenticatorRow(account: account)
                    .border(Color.gray)
                    .onAppear(perform: {let _ = self.timeManager.updateTimer})
                }
            }.padding()
        }
    }
    
    func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
//    func addAccount(id: UUID, service: String, account: String, key: String, interval: Int16,
//    digits: Int16) {
//      // 1
//        let newAccount = Account(context: managedObjectContext)
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

struct AuthenticatorList_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatorList().environmentObject(TimeManager()).frame(minWidth: 360,
        maxWidth:.infinity,
        maxHeight: .infinity)
    }
}
