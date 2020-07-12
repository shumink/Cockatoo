//
//  HeaderBar.swift
//  Cockatoo
//
//  Created by Shumin Kong on 30/6/20.
//  Copyright © 2020 Shumin Kong. All rights reserved.
//

import SwiftUI
import CodeScanner
import os

struct HeaderBar: View {
    @State var showAddMenu: Bool = false
    @State var isActionViewPresented = false
    @State var isSettingViewPresented = false
    @State var isAlertPresented = false
    @State var isEditing = false
    @State var data: [String:String] = ["":""]
    @State var actionViewMode = ActionViewMode.qr
    @Binding var search: String
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        
        
        VStack(spacing: 5) {
            
            HStack {
                Text("Cockatoo").font(.system(.largeTitle, design: .rounded)).bold()
                Spacer()
                
                Button(action: {
                    self.isSettingViewPresented.toggle()
                }) {
                    Image(systemName: "ellipsis").imageScale(.large)
                }.sheet(isPresented: $isSettingViewPresented, content: {
                    SettingView().environment(\.managedObjectContext, self.managedObjectContext)
                }).padding(.trailing)
                
                Button(action: {
                    self.showAddMenu.toggle()
                }) {
                    Image(systemName: "plus").imageScale(.large)
                }.actionSheet(isPresented: self.$showAddMenu) {
                    ActionSheet(title: Text("Where do you want to import from?"), buttons: [.default(Text("QR Code"), action: {
                        self.actionViewMode = .qr
                        self.isActionViewPresented = true}),
                                                                                            .default(Text("Manual"), action: {
                                                                                                self.actionViewMode = .manual
                                                                                                self.isActionViewPresented = true}),
                                                                                            .destructive(Text("Cancel"))])
                }.sheet(isPresented: $isActionViewPresented) {
                    if self.actionViewMode == .manual {
                        ManualView(callback: {
                            self.isActionViewPresented = false
                        }).environment(\.managedObjectContext, self.managedObjectContext)
                    } else if self.actionViewMode == .qr {
                        CodeScannerView(codeTypes: [.qr], completion: self.handleScan)
                    } else {
                        ManualView(timeBased: self.data["host"]! == "totp",
                                   service: self.data["issuer"]! ,
                                   account: self.data["path"]!,
                                   key: self.data["secret"]!,
                                   interval: self.data["period"]!,
                                   digits: self.data["digits"]!,
                                   counter: self.data["counter"]!,
                                   callback: {
                                    self.isActionViewPresented = false
                        })
                            .environment(\.managedObjectContext, self.managedObjectContext)
                    }
                }
                
            }
            .padding(.leading)
            .padding(.trailing)
            
            HStack {
                TextField("Search ...", text: $search)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                    .onTapGesture {
                        self.isEditing = true
                    }.overlay(
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                    )
                if isEditing {
                    Button(action: {
                        self.isEditing = false
                        self.search = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                    }) {
                        Text("Cancel")
                    }
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
            }
            .padding(.leading)
            .padding(.trailing)
            Divider()

        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isActionViewPresented = false
        switch result {
        case .success(let code):
            self.data = validateOTP(code: code)
            if self.data != [:] {
                self.actionViewMode = .qrDone
                self.isActionViewPresented = true
            }
        case .failure(let error):
            print(error)
            print("Scanning failed")
        }
    }
    
}

enum ActionViewMode {
    case qr
    case manual
    case qrDone
}


struct HeaderBar_Previews: PreviewProvider {
    static var previews: some View {
        HeaderBar(search: .constant(""))
    }
}
