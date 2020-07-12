//
//  ExportView.swift
//  CockatooOTP
//
//  Created by Shumin Kong on 12/7/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI

struct ExportView: View {
    let accountsPerImage: Int = 8
    let attemptID: Int32 = Int32.random(in:Int32.min ... Int32.max)
    var fetchRequest: FetchRequest<Account>
    //    var results: FetchedResults<Account> { fetchRequest.wrappedValue }
    @EnvironmentObject var timeManager: TimeManager

    @Environment(\.managedObjectContext) var managedObjectContext
//    var account: Account


    init() {
        self.fetchRequest = FetchRequest<Account> (
            entity: Account.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Account.favTime, ascending: false),
                NSSortDescriptor(keyPath: \Account.createdTime, ascending: false),
            ]
        )
        
//        let acc1 = Account(context: self.managedObjectContext)
//        acc1.account = "shuminkong@protonmail.com"
//        acc1.service = "Protonmail"
//        acc1.digits = 6
//        acc1.interval = 30
//        acc1.type = "totp"
//        acc1.key = "AWSGRJH7572OE3KJZEM4SNDVHD57DKDGQQ7JYWEZR5ZWOXAFJCOJDI5D"
//        acc1.favTime = Date(timeIntervalSince1970: 0)
//        acc1.createdTime = Date(timeIntervalSince1970: 0)
//        acc1.counter = 0
//        self.account = acc1
//        print( self.fetchRequest)
        
    }
    
    func accounts2Image(index: Int32) -> UIImage {
//        do {
//            let data = try exportToGoogleAuth(accounts:accounts, index: index, id: attemptID)
//
//        } catch(let error) {
//            print(error)
//            let data = "" // better error handling
//        }
        let accounts = [self.fetchRequest.wrappedValue.first! as Account]
        guard let data = try? exportToGoogleAuth(accounts:accounts, index: index, id: attemptID) else {
            return UIImage()
        }

        
        let exportedString = "otpauth-migration://offline?data=\(data)"
        print(exportedString)
        return generateQRCode(from: exportedString)

    }

    var body: some View {
        List(fetchRequest.wrappedValue, id: \.id) { account in
//            AuthenticatorRow(account: account)
//            Text(account.key!)
//            Image
            Image(uiImage: self.accounts2Image(index: 0))
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)

        }
        .animation(.default)
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
        })

//        Image(uiImage: accounts2Image(accounts: [self.account], index: 0))
//        .resizable()
//        .scaledToFit()
//        .frame(width: 200, height: 200)
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
    }
}
