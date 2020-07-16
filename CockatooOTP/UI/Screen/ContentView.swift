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

        }.frame(maxWidth: .infinity,
                maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let timeManager = TimeManager()
        let acc1 = Account(context: context)
        acc1.account = "shuminkong@protonmail.com"
        acc1.service = "Protonmail"
        acc1.digits = 6
        acc1.interval = 30
        acc1.type = "totp"
        acc1.key = "AWSGRJH7572OE3KJZEM4SNDVHD57DKDGQQ7JYWEZR5ZWOXAFJCOJDI5D"
        acc1.favTime = Date(timeIntervalSince1970: 0)
        acc1.createdTime = Date(timeIntervalSince1970: 0)
        acc1.counter = 0
        
        let acc2 = Account(context: context)
        acc2.account = "shuminkong@protonmail.com"
        acc2.service = "Protonmail"
        acc2.digits = 6
        acc2.interval = 30
        acc2.type = "totp"
        acc2.key = "jcxjomietvmuwnvm4nbllhmli6k55xjjf74xf2apzm7z2rvayfrsycvi"
        acc2.favTime = Date(timeIntervalSince1970: 0)
        acc2.createdTime = Date(timeIntervalSince1970: 0)
        acc2.counter = 0
//
//        do {
//            try context.save()
//        } catch {
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }

        
        return ContentView().environment(\.managedObjectContext, context).environmentObject(timeManager)
    }
}
