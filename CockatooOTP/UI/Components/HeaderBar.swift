//
//  HeaderBar.swift
//  Cockatoo
//
//  Created by Shumin Kong on 30/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI

struct HeaderBar: View {
    @State var query:String = ""
    @State var showAddMenu: Bool = false
    @State var isMainActionPresented = false
    @State var isActionViewPresented = false
    @State var actionViewMode = ActionViewMode.qr
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        
        HStack {
            Button(action: {
                print("Edit button was tapped")
            }) {
                Image(systemName: "slider.horizontal.3")
            }
            TextField("Search", text:$query)
                .padding()
                .cornerRadius(10)
                .border(Color.secondary)
            Button(action: {
                self.showAddMenu.toggle()
            }) {
                Image(systemName: "plus")
            }.actionSheet(isPresented: self.$showAddMenu) {
                ActionSheet(title: Text("Where do you want to import from?"), buttons: [.default(Text("QR Code"), action: {
                                self.actionViewMode = .qr
                                self.isActionViewPresented = true}),
                             .default(Text("Manual"), action: {
                                self.actionViewMode = .manual
//                                self.actionViewMode
                                self.isActionViewPresented = true}),
                             .destructive(Text("Cancel"))])
            }.sheet(isPresented: $isActionViewPresented) {
                self.actionViewMode.view.environment(\.managedObjectContext, self.managedObjectContext)
            }
            
            
        }.frame(maxWidth: .infinity,
                minHeight: 36)
        .padding()
        
    }
}

enum ActionViewMode {
    case qr
    case manual
}

extension ActionViewMode {
    var view: some View {
        switch self {
            case .qr: return ManualView()
            case .manual: return ManualView()
        }
    }
}


struct HeaderBar_Previews: PreviewProvider {
    static var previews: some View {
        HeaderBar()
    }
}
